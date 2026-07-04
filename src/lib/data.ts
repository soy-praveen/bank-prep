import type { MockDef, Question, QuestionSet, SectionBank, SectionId, Stage, Trick } from '../types';
import syllabusJson from '../data/syllabus.json';
import english from '../data/questions/english.json';
import quant from '../data/questions/quant.json';
import reasoning from '../data/questions/reasoning.json';
import general from '../data/questions/general.json';
import tricksJson from '../data/tricks.json';
import mocksJson from '../data/mocks.json';

export const syllabus = syllabusJson;
export const tricks = tricksJson as Trick[];
/** Curated fixed-paper mocks (reconstructed PYQ papers etc.) */
export const curatedMocks = mocksJson as MockDef[];

// Extracted previous-year banks: every JSON dropped into questions/pyq/ is merged automatically.
const pyqModules = import.meta.glob('../data/questions/pyq/*.json', { eager: true }) as Record<
  string,
  SectionBank | { default: SectionBank }
>;
const pyqBanks: SectionBank[] = Object.values(pyqModules).map((m) =>
  'default' in m ? (m.default as SectionBank) : (m as SectionBank),
);

const allBanks: SectionBank[] = [
  english as SectionBank,
  quant as SectionBank,
  reasoning as SectionBank,
  general as SectionBank,
  ...pyqBanks,
];

export const SECTION_META: Record<SectionId, { name: string; short: string }> = {
  english: { name: 'English Language', short: 'English' },
  quant: { name: 'Quantitative Aptitude', short: 'Quant' },
  reasoning: { name: 'Reasoning Ability', short: 'Reasoning' },
  general: { name: 'General / Banking Awareness', short: 'GA' },
};

export const allQuestions: Question[] = allBanks.flatMap((b) => b.questions);
export const questionById = new Map<string, Question>(allQuestions.map((q) => [q.id, q]));
export const setById = new Map<string, QuestionSet>(
  allBanks.flatMap((b) => b.sets).map((s) => [s.id, s]),
);

export function questionsFor(section: SectionId, opts?: { stage?: Stage; topic?: string }): Question[] {
  return allQuestions.filter(
    (q) =>
      q.section === section &&
      (!opts?.topic || q.topic === opts.topic) &&
      (!opts?.stage || opts.stage === 'both' || q.stage === opts.stage || q.stage === 'both'),
  );
}

export function topicName(section: SectionId, slug: string): string {
  for (const stage of syllabus.stages) {
    for (const sec of stage.syllabus) {
      if (sec.section !== section) continue;
      const t = sec.topics.find((t) => t.slug === slug);
      if (t) return t.name;
    }
  }
  return slug;
}

/** All topic slugs (with names) available in a section's bank, with counts. */
export function bankTopics(section: SectionId): { slug: string; name: string; count: number }[] {
  const counts = new Map<string, number>();
  for (const q of allQuestions) if (q.section === section) counts.set(q.topic, (counts.get(q.topic) ?? 0) + 1);
  return [...counts.entries()]
    .map(([slug, count]) => ({ slug, name: topicName(section, slug), count }))
    .sort((a, b) => b.count - a.count);
}

// ---------- deterministic mock assembly ----------

function mulberry32(seed: number) {
  let a = seed >>> 0;
  return () => {
    a |= 0;
    a = (a + 0x6d2b79f5) | 0;
    let t = Math.imul(a ^ (a >>> 15), 1 | a);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

function shuffled<T>(arr: T[], rng: () => number): T[] {
  const a = [...arr];
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(rng() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a;
}

/**
 * Sample `count` questions from a pool, keeping set members contiguous and whole.
 * Falls back to whatever is available if the pool is smaller than `count`.
 */
export function sampleSection(pool: SectionId, stage: Stage, count: number, seed: number): string[] {
  const rng = mulberry32(seed);
  const candidates = questionsFor(pool, { stage });
  const groups = new Map<string, Question[]>();
  for (const q of candidates) {
    const key = q.setId ?? `single:${q.id}`;
    if (!groups.has(key)) groups.set(key, []);
    groups.get(key)!.push(q);
  }
  const setGroups = shuffled([...groups.entries()].filter(([k]) => !k.startsWith('single:')), rng);
  const singles = shuffled([...groups.entries()].filter(([k]) => k.startsWith('single:')).map(([, v]) => v[0]), rng);

  const picked: Question[] = [];
  for (const [, members] of setGroups) {
    if (picked.length + members.length <= count) picked.push(...members);
  }
  for (const s of singles) {
    if (picked.length >= count) break;
    picked.push(s);
  }
  return picked.slice(0, count).map((q) => q.id);
}

export interface PatternSection {
  name: string;
  pool: SectionId;
  questions: number;
  marks: number;
  minutes: number;
}

export function stagePattern(stageId: 'prelims' | 'mains') {
  const stage = syllabus.stages.find((s) => s.id === stageId)!;
  return stage.pattern as {
    totalQuestions: number;
    totalMarks: number;
    totalMinutes: number;
    sectionalTiming: boolean;
    sections: PatternSection[];
    descriptive?: { name: string; marks: number; minutes: number; components: string[] };
  };
}

/** Build the nth generated mock for a stage. Deterministic per (stage, n). */
export function buildGeneratedMock(stageId: 'prelims' | 'mains', n: number) {
  const pattern = stagePattern(stageId);
  const seedBase = (stageId === 'prelims' ? 1000 : 2000) + n * 97;
  return {
    id: `gen-${stageId}-${n}`,
    name: `${stageId === 'prelims' ? 'Prelims' : 'Mains'} Mock ${String(n).padStart(2, '0')}`,
    stage: stageId,
    description:
      stageId === 'prelims'
        ? 'Full pattern: 100 questions, 60 minutes, sectional timers of 20 minutes.'
        : 'Objective pattern: 170 questions across 4 sections, 180 minutes.',
    sections: pattern.sections.map((sec, i) => ({
      name: sec.name,
      pool: sec.pool,
      minutes: sec.minutes,
      marksPerQuestion: sec.marks / sec.questions,
      negativeFraction: 0.25,
      questionIds: sampleSection(sec.pool, stageId, sec.questions, seedBase + i * 13),
    })),
  };
}

/** How many distinct full mocks the current pool can serve (rough guide shown in UI). */
export function poolCoverage(stageId: 'prelims' | 'mains') {
  const pattern = stagePattern(stageId);
  return pattern.sections.map((sec) => {
    const have = questionsFor(sec.pool, { stage: stageId }).length;
    return { name: sec.name, need: sec.questions, have };
  });
}
