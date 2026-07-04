# BankPrep — SBI PO Preparation Suite

A personal, static web app for SBI PO (and later other bank exam) preparation. Built for two people studying together; all progress lives in the browser (localStorage), no backend.

## Features

- **Mock tests** on the verified SBI PO 2025-26 pattern — Prelims (English 40 / Quant 30 / Reasoning 30, 20-minute sectional timers) and Mains (170 Q / 200 marks across 4 sections), with the real marking scheme including 1/4 negative marking and per-section marks-per-question.
- **Exam-faithful player**: sectional locking, question palette (answered / not answered / marked / not visited), mark-for-review, per-question time tracking, auto-submit on timer expiry, resume after refresh.
- **Practice hub**: topic-wise practice with instant explanations, or timed drills with negative marking.
- **Analytics**: score trends, sectional breakdowns, topic-accuracy bars, weak-topic surfacing, full solutions review.
- **Syllabus browser** with priority weightage and live question-bank coverage.
- **Tricks library**: speed techniques for Quant, Reasoning, and English.
- **Pomodoro focus timer** with daily logs and streak tracking.
- **Two profiles** with separate progress, plus JSON export/import.

## Stack

Vite + React + TypeScript, Tailwind CSS v4, Framer Motion, Lucide icons, HashRouter (works on GitHub Pages with zero config). Fonts are bundled (Inter Variable, Space Grotesk Variable) — the site is fully self-contained.

## Data model

Question banks live in `src/data/questions/*.json`, validated by `scripts/validate-bank.mjs`:

```
node scripts/validate-bank.mjs src/data/questions/*.json
```

- `syllabus.json` — exam patterns + topic trees (the source of truth for topic slugs)
- `questions/{english,quant,reasoning,general}.json` — `{ sets, questions }`; sets carry shared context (RC passages, DI tables, puzzles)
- `tricks.json` — speed-technique library
- Questions are tagged `source.kind: "generated" | "pyq"` so previous-year extractions and generated practice items stay distinguishable.

Mocks are assembled deterministically from the pools (`buildGeneratedMock`), keeping sets contiguous — the same mock number always produces the same paper, and new mocks unlock as the bank grows.

## Develop

```
npm install
npm run dev     # local dev server
npm run build   # production build to dist/
```

## Deploy

Pushes to `main` auto-deploy via GitHub Actions (`.github/workflows/deploy.yml`).
One-time setup: repo Settings → Pages → Source: **GitHub Actions**.
