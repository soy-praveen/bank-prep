#!/usr/bin/env python3
"""Build practice + pyq index.json files and hard-validate every asset."""
import json, os, re, sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PRACTICE = os.path.join(ROOT, 'assets/data/practice')
PYQ = os.path.join(ROOT, 'assets/data/pyq')

CORE = {
    'quant-di', 'quant-simplification-series', 'quant-quadratic-qc-ds',
    'quant-arithmetic', 'reasoning-puzzles', 'reasoning-syllogism-inequality',
    'reasoning-misc', 'english-rc-cloze', 'english-grammar',
}
EMOJI = re.compile('[\U0001F300-\U0001FAFF]')
errors = []

def category(slug):
    if slug.startswith('mini-mock'): return 'mock'
    if 'trap-busters' in slug or slug == 'quant-speed-drill': return 'strategy'
    if slug in CORE: return 'core'
    return 'volume'

def scan(s, where):
    if isinstance(s, str) and EMOJI.search(s):
        errors.append(f'emoji in {where}')

# ---- practice --------------------------------------------------------------
entries = []
for fn in sorted(os.listdir(PRACTICE)):
    if not fn.endswith('.json') or fn == 'index.json':
        continue
    slug = fn[:-5]
    with open(os.path.join(PRACTICE, fn)) as f:
        m = json.load(f)
    qs = m['questions']
    if not qs:
        errors.append(f'{slug}: empty'); continue
    ids = set()
    for q in qs:
        qid = q.get('id', '?')
        if qid in ids: errors.append(f'{slug}: dup id {qid}')
        ids.add(qid)
        if not q.get('question', '').strip():
            errors.append(f'{qid}: empty question')
        opts = q.get('options')
        if opts is not None:
            if len(opts) != 5: errors.append(f'{qid}: {len(opts)} options')
            cor = q.get('correct')
            if cor is None or not (0 <= cor <= 4):
                errors.append(f'{qid}: bad correct {cor}')
        else:
            if not (q.get('answerText') or '').strip():
                errors.append(f'{qid}: non-MCQ without answerText')
        if m.get('kind') != 'speed' and not q.get('solution', '').strip():
            errors.append(f'{qid}: empty solution')
        for field in ('question', 'solution', 'context', 'trick', 'answerText'):
            scan(q.get(field) or '', f'{qid}.{field}')
        for o in (opts or []):
            scan(o, f'{qid}.option')
    if slug.startswith('mini-mock'):
        non_mcq = [q['id'] for q in qs if q.get('options') is None]
        if non_mcq:
            errors.append(f'{slug}: non-MCQ in mini-mock: {non_mcq}')
    entries.append({
        'slug': slug,
        'title': m['title'],
        'section': m['section'],
        'kind': m.get('kind', 'quiz'),
        'category': category(slug),
        'count': len(qs),
    })

cat_order = {'core': 0, 'volume': 1, 'strategy': 2, 'mock': 3}
sec_order = {'quant': 0, 'reasoning': 1, 'english': 2, 'mixed': 3}
entries.sort(key=lambda e: (cat_order[e['category']],
                            sec_order.get(e['section'], 9), e['slug']))
with open(os.path.join(PRACTICE, 'index.json'), 'w') as f:
    json.dump(entries, f, indent=1)

# ---- pyq -------------------------------------------------------------------
pyq_entries = []
for fn in sorted(os.listdir(PYQ)):
    if not fn.endswith('.json') or fn == 'index.json':
        continue
    with open(os.path.join(PYQ, fn)) as f:
        p = json.load(f)
    year = int(re.search(r'(\d{4})', fn).group(1))
    set_ids = {s['id'] for s in p.get('sets', [])}
    sections = {}
    for q in p['questions']:
        sections[q['section']] = sections.get(q['section'], 0) + 1
        if len(q.get('options', [])) != 5:
            errors.append(f'{fn}:{q["id"]}: options != 5')
        if not (0 <= q.get('correct', -1) <= 4):
            errors.append(f'{fn}:{q["id"]}: bad correct')
        if q.get('setId') and q['setId'] not in set_ids:
            errors.append(f'{fn}:{q["id"]}: dangling setId')
    pyq_entries.append({
        'file': fn,
        'year': year,
        'title': f'SBI PO Prelims {year}',
        'sections': sections,
    })

with open(os.path.join(PYQ, 'index.json'), 'w') as f:
    json.dump(pyq_entries, f, indent=1)

total_p = sum(e['count'] for e in entries)
total_y = sum(sum(e['sections'].values()) for e in pyq_entries)
print(f'practice modules: {len(entries)} ({total_p} questions)')
print(f'pyq papers: {len(pyq_entries)} ({total_y} questions)')
print(f'grand total: {total_p + total_y} questions')
if errors:
    print(f'\n{len(errors)} VALIDATION ERRORS:')
    for e in errors[:40]:
        print(' -', e)
    sys.exit(1)
print('validation: CLEAN')
