# BankPrep — working notes for Claude sessions

Personal SBI PO prep site for two users. Static Vite + React + TS app, GitHub Pages via Actions on `main`. Development branch: `claude/bank-exam-prep-site-0h1sml`.

## Hard rules

- NO emojis anywhere in the app or data — icons come from lucide-react only.
- Question data must pass `npm run validate` (scripts/validate-bank.mjs) before committing.
- Topic slugs are defined ONLY in `src/data/syllabus.json`; never invent new slugs in question files without adding them to the syllabus first.
- Exam pattern numbers (SBI PO 2025-26 revised) are verified — don't "fix" them from memory: Prelims E40/Q30/R30, 20-min sectional timers; Mains R&CA 40Q/60m/50min, DA&I 30Q/60m/45min, GEB 60Q/60m/45min, English 40Q/20m/40min, Descriptive 30 marks/30 min.

## Data model

- `src/data/questions/{english,quant,reasoning,general}.json` — `{ sets, questions }`. Sets hold shared context (RC passage, DI table, puzzle); member questions reference them via `setId`. Questions: exactly 5 options, `correct` is a 0-based index, mini-markdown (`**bold**`, `\n`, pipe tables) in question/context/explanation.
- `source.kind`: `"pyq"` for questions extracted from the books (with `ref` + `year`), `"generated"` for original ones.
- Mocks are assembled at runtime (`buildGeneratedMock` in src/lib/data.ts) — deterministic per (stage, n), set-aware. No mocks.json needed unless curating fixed papers (e.g. reconstructed real PYQ papers).

## Book extraction (phase 2)

Source books live in the user's Drive folder "Claude" (see `scripts/books-manifest.json`). Once the folder is link-shared, `bash scripts/fetch-books.sh` downloads them to `books/` (git-ignored — never commit the PDFs). Extraction: fan out agents per book/chunk, Read PDFs page-by-page, emit questions in the bank schema with `source.kind: "pyq"`, validate, merge. Keep IDs namespaced per book (e.g. `pyq-disha32-...`).

## UI conventions

Tailwind v4 theme tokens in src/index.css (semantic: bg/surface/raised/sunken/ink/accent/teal/danger/warn/violet). Dark is default theme. Framer-motion for transitions (respect the existing 200-260ms feel). Components in src/components/ui.tsx; keep pages composed from those primitives.
