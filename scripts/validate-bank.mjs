// Validates question bank JSON files against the schema + syllabus slugs.
// Usage: node scripts/validate-bank.mjs src/data/questions/english.json [...more]
import { readFileSync } from 'node:fs';

const syllabus = JSON.parse(readFileSync(new URL('../src/data/syllabus.json', import.meta.url)));
const slugsBySection = {};
for (const stage of syllabus.stages) {
  for (const sec of stage.syllabus) {
    slugsBySection[sec.section] ??= new Set();
    for (const t of sec.topics) slugsBySection[sec.section].add(t.slug);
  }
}

const SECTIONS = ['english', 'quant', 'reasoning', 'general'];
const STAGES = ['prelims', 'mains', 'both'];
let failed = false;
const err = (f, m) => { failed = true; console.error(`[${f}] ${m}`); };

const seenIds = new Set();
for (const file of process.argv.slice(2)) {
  let bank;
  try {
    bank = JSON.parse(readFileSync(file, 'utf8'));
  } catch (e) {
    err(file, `JSON parse failed: ${e.message}`);
    continue;
  }
  const sets = new Map((bank.sets ?? []).map(s => [s.id, s]));
  for (const s of bank.sets ?? []) {
    if (!s.id || !s.context || !s.title) err(file, `set ${s.id ?? '?'}: missing id/title/context`);
    if (!SECTIONS.includes(s.section)) err(file, `set ${s.id}: bad section ${s.section}`);
    if (!slugsBySection[s.section]?.has(s.topic)) err(file, `set ${s.id}: unknown topic ${s.topic}`);
  }
  const setUse = new Map();
  for (const q of bank.questions ?? []) {
    const id = q.id ?? '?';
    if (seenIds.has(q.id)) err(file, `duplicate id ${id}`);
    seenIds.add(q.id);
    if (!SECTIONS.includes(q.section)) err(file, `${id}: bad section ${q.section}`);
    if (!STAGES.includes(q.stage)) err(file, `${id}: bad stage ${q.stage}`);
    if (![1, 2, 3].includes(q.difficulty)) err(file, `${id}: bad difficulty ${q.difficulty}`);
    if (!slugsBySection[q.section]?.has(q.topic)) err(file, `${id}: unknown topic '${q.topic}' for section ${q.section}`);
    if (!Array.isArray(q.options) || q.options.length !== 5) err(file, `${id}: must have exactly 5 options`);
    if (!Number.isInteger(q.correct) || q.correct < 0 || q.correct >= (q.options?.length ?? 0)) err(file, `${id}: bad correct index`);
    if (!q.question?.trim() || !q.explanation?.trim()) err(file, `${id}: empty question/explanation`);
    if (!q.source?.kind) err(file, `${id}: missing source.kind`);
    if (q.setId) {
      if (!sets.has(q.setId)) err(file, `${id}: setId ${q.setId} not found in file`);
      setUse.set(q.setId, (setUse.get(q.setId) ?? 0) + 1);
    }
    if (/[\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}]/u.test(q.question + q.options.join('') + q.explanation)) {
      err(file, `${id}: contains emoji`);
    }
  }
  for (const [sid] of sets) {
    if (!setUse.get(sid)) err(file, `set ${sid}: no questions reference it`);
  }
  const n = (bank.questions ?? []).length;
  console.log(`${file}: ${n} questions, ${sets.size} sets ${failed ? '' : 'OK'}`);
}
process.exit(failed ? 1 : 0);
