# PYQ Extraction Guide (read fully before extracting)

You are extracting one previous-year paper into `/home/user/bank-prep/src/data/questions/pyq/<paper-id>.json`. Text chunks live in `/home/user/bank-prep/books-text/<book>/pNNNN-NNNN.txt` (10 pages per file; a page N is in the file whose range contains N). Pages are delimited by `=== PAGE N ===` lines.

## Output shape

```
{
  "sets": [ { "id", "section", "topic", "title", "context" } ],
  "questions": [ { "id", "stage", "section", "topic", "difficulty", "setId"?, "question", "options" (exactly 5), "correct" (0-4), "explanation", "source": {"kind":"pyq","ref":"<paper name> (memory-based, <book short name>)","year":<year>}, "tags":["pyq", ...] } ],
  "paper": { "id", "name", "exam", "stage", "year", "sections": [ { "name", "pool", "minutes", "marksPerQuestion", "questionIds": [in paper order] } ] }
}
```

- `pool` is one of: english | quant | reasoning | general. `stage`: "prelims" or "mains" (match the paper).
- IDs: questions `pyq-<idprefix>-q001...` in paper order; sets `pyq-<idprefix>-set1...`.
- Prelims paper sections: minutes = 20 each. Mains sections: minutes = ceil(questionCount x 1.2). marksPerQuestion = 1 unless your dispatch prompt says otherwise.
- The paper's `sections[].questionIds` may only reference questions you actually extracted.

## Topic slugs (classify every question)

- reasoning: seating-arrangement, puzzles, syllogism, inequality, blood-relations, direction-sense, order-ranking, coding-decoding, alphanumeric-series, data-sufficiency-reasoning, input-output, logical-verbal-reasoning, computer-aptitude
- quant: data-interpretation, simplification-approximation, number-series, quadratic-equations, quantity-comparison, data-sufficiency, percentages, profit-loss, simple-compound-interest, ratio-proportion, averages, ages, time-work, pipes-cisterns, speed-time-distance, trains, boats-streams, mixtures-alligations, partnership, mensuration, permutation-combination, probability, caselet-di
- english: reading-comprehension, cloze-test, error-spotting, sentence-improvement, para-jumbles, fillers, phrase-replacement, match-the-columns, para-completion, word-usage, vocabulary, sentence-connectors
- general (mains GA sections): banking-awareness, financial-awareness, current-affairs, economy, static-gk

## Extraction rules (lessons from the pilot)

1. Read ALL question pages AND solution pages before writing. Answers come from the book's key; cross-check every question number against the key.
2. Group shared-context questions into sets (RC, cloze, each DI chart, each puzzle block). Rebuild DI tables as pipe-markdown. Puzzle clues: one per line with \n.
   RC/cloze PASSAGES: do NOT reproduce them verbatim — verbatim passages have repeatedly tripped output content filters (and are the one part of these books with real authorship). Write a faithful condensed paraphrase in your own words, first line "[Passage paraphrased from the original]", preserving exactly the bolded words/phrases the questions interrogate and any sentence a question quotes directly. If a set still trips the filter, skip it and report the numbers.
3. Puzzle solutions are often a bare answer letter — RE-SOLVE the puzzle from its clues yourself, verify your arrangement matches all the key's answers for that set, and state the final arrangement in explanations.
4. Bar/line charts are images (no text). Reverse-engineer the data table from the solutions' arithmetic; cross-check across the set's questions. Tag such questions "reconstructed-data". If the data cannot be pinned down, SKIP the set.
5. Book typos happen (inconsistent coding logic, mislabeled entities). If the key's answer can't be derived cleanly, keep the key's answer with a hedged explanation, tag "book-typo-suspect". Never force a false derivation.
6. Skip unrecoverable questions (missing options/answers, hopeless garble) — never invent. Track skip numbers for your reply.
7. Exactly 5 options; if the source shows only 4 recoverable options and the answer is among them, add a plausible 5th ("None of these") ONLY if the original format clearly had it; otherwise skip.
8. Strip watermarks/URLs from all text. NO emojis. Keep original exam phrasing.
9. GA/current-affairs questions in mains papers: extract as-is with topic current-affairs (or banking-awareness/static-gk when timeless); add tag "dated-ca" since facts age.

## Write protocol — MANDATORY (single big writes die at 64k output tokens)

Write MANY SMALL part files, EACH IN ITS OWN response turn. Hard limits per single Write call: **max ~15-20 questions, max ~400 lines**. Multiple agents have died emitting more — one response turn must never carry a whole section.
- Name parts freely: `<paper-id>.part-r1.json`, `.part-r2.json`, `.part-q1.json`, `.part-e1.json`, `.part-g1.json`, ... each `{"sets":[...],"questions":[...]}` (put a set in the same part as its first member question)
- `<paper-id>.part-meta.json` -> `{"paper":{...}}`
- Never combine two part writes in one response, and never emit question JSON in your text output — only inside Write calls.

Merge (adapt the part list):
```
cd /home/user/bank-prep && node -e "const fs=require('fs');const base='src/data/questions/pyq/<paper-id>';const names=['reasoning','quant','english','meta'];const parts=names.map(x=>JSON.parse(fs.readFileSync(base+'.part-'+x+'.json','utf8')));const meta=parts.find(p=>p.paper);const out={sets:parts.flatMap(p=>p.sets||[]),questions:parts.flatMap(p=>p.questions||[]),paper:meta.paper};fs.writeFileSync(base+'.json',JSON.stringify(out,null,1));names.forEach(x=>fs.unlinkSync(base+'.part-'+x+'.json'));console.log('merged',out.questions.length,'questions',out.sets.length,'sets')"
```

Validate until clean:
```
node scripts/validate-bank.mjs src/data/questions/pyq/<paper-id>.json
node -e "const b=require('/home/user/bank-prep/src/data/questions/pyq/<paper-id>.json');const ids=new Set(b.questions.map(q=>q.id));for(const s of b.paper.sections)for(const id of s.questionIds)if(!ids.has(id))throw new Error('missing '+id);console.log('paper meta OK',b.paper.sections.map(s=>s.name+':'+s.questionIds.length).join(' '))"
```

## Reply format (max 10 lines)

Questions extracted per section; sets; skipped numbers + reasons; answer-key coverage; any low-confidence reconstructions.
