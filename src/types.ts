// Core data model for the question bank, mocks, and user state.

export type SectionId = 'english' | 'quant' | 'reasoning' | 'general';
export type Stage = 'prelims' | 'mains' | 'both';
export type Difficulty = 1 | 2 | 3; // easy | moderate | hard

export interface QuestionSource {
  kind: 'generated' | 'pyq';
  /** Book / paper reference, e.g. "SBI PO Prelims 2019 (memory based)" */
  ref?: string;
  year?: number;
}

export interface Question {
  id: string;
  stage: Stage;
  section: SectionId;
  /** Topic slug — must exist in the syllabus topic tree */
  topic: string;
  difficulty: Difficulty;
  /** Present when the question belongs to a shared-context group (RC / DI / puzzle) */
  setId?: string;
  /** Mini-markdown: **bold**, *italic*, `code`, tables via | pipes, \n line breaks */
  question: string;
  options: string[];
  /** Index into options */
  correct: number;
  explanation: string;
  source: QuestionSource;
  tags?: string[];
}

export interface QuestionSet {
  id: string;
  section: SectionId;
  topic: string;
  title: string;
  /** Shared context shown alongside every member question (passage, puzzle text, DI table) */
  context: string;
}

export interface SectionBank {
  sets: QuestionSet[];
  questions: Question[];
}

/** One timed section inside a mock definition */
export interface MockSection {
  /** Exam-paper section label, e.g. "Data Analysis & Interpretation" */
  name: string;
  /** Which base pool the questions come from */
  pool: SectionId;
  minutes: number;
  /** Marks awarded per question (SBI PO mains varies: 1.5, 2, 1, 0.5) */
  marksPerQuestion: number;
  /** Fraction of the question's marks lost on a wrong answer (0.25 = 1/4) */
  negativeFraction: number;
  questionIds: string[];
}

export interface MockDef {
  id: string;
  name: string;
  stage: Exclude<Stage, 'both'>;
  description: string;
  sections: MockSection[];
}

export interface Trick {
  id: string;
  section: SectionId;
  topic: string;
  title: string;
  summary: string;
  /** Mini-markdown body */
  body: string;
}

// ---------- user state (localStorage) ----------

export type QStatus = 'unseen' | 'seen' | 'answered' | 'marked' | 'answeredMarked';

export interface QuestionAttemptState {
  status: QStatus;
  choice: number | null;
  timeSec: number;
}

export interface SessionSectionResult {
  name: string;
  pool: SectionId;
  attempted: number;
  correct: number;
  wrong: number;
  score: number;
  maxScore: number;
  timeUsedSec: number;
}

export interface TestResult {
  id: string;
  mockId: string;
  mockName: string;
  stage: Exclude<Stage, 'both'>;
  kind: 'mock' | 'drill' | 'practice';
  finishedAt: number;
  totalScore: number;
  maxScore: number;
  accuracy: number; // correct / attempted
  attempted: number;
  totalQuestions: number;
  sections: SessionSectionResult[];
  /** questionId -> attempt info, for solutions review + topic analytics */
  answers: Record<string, { choice: number | null; correct: boolean; timeSec: number; topic: string; section: SectionId }>;
}

export interface PomodoroLog {
  dateKey: string; // YYYY-MM-DD
  focusMinutes: number;
  sessions: number;
}

export interface Profile {
  id: string;
  name: string;
  /** accent hue used for the avatar */
  hue: number;
  createdAt: number;
}

export interface ProfileState {
  results: TestResult[];
  pomodoro: PomodoroLog[];
  /** topic slug -> cumulative practice stats */
  topicStats: Record<string, { attempted: number; correct: number; timeSec: number }>;
  bookmarks: string[]; // question ids
  lastActive: number;
}
