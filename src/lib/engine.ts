import { useCallback, useEffect, useMemo, useRef, useState } from 'react';
import type { MockDef, QStatus, QuestionAttemptState, TestResult } from '../types';
import { questionById } from './data';

export interface SessionState {
  mock: MockDef;
  kind: 'mock' | 'drill' | 'practice';
  si: number; // current section index
  qi: number; // question index within section
  answers: Record<string, QuestionAttemptState>;
  /** epoch ms when the current section expires (mock/drill) */
  sectionEndsAt: number;
  startedAt: number;
  /** seconds actually used in completed sections */
  sectionTimeUsed: number[];
  finished: boolean;
  /** snapshot of remaining section seconds at save time, used to resume cleanly */
  savedRemainingSec?: number;
}

const sessionKey = (pid: string) => `bp:session:${pid}`;

export function loadSession(pid: string): SessionState | null {
  try {
    const raw = localStorage.getItem(sessionKey(pid));
    if (!raw) return null;
    const s = JSON.parse(raw) as SessionState;
    // resume with the time that was left when the session was last saved,
    // rather than counting the away-time against the section clock
    if (!s.finished && s.savedRemainingSec !== undefined) {
      s.sectionEndsAt = Date.now() + Math.max(5, s.savedRemainingSec) * 1000;
    }
    return s;
  } catch {
    return null;
  }
}
export function clearSession(pid: string) {
  localStorage.removeItem(sessionKey(pid));
}

function persist(pid: string, s: SessionState) {
  const snapshot: SessionState = { ...s, savedRemainingSec: Math.max(0, (s.sectionEndsAt - Date.now()) / 1000) };
  localStorage.setItem(sessionKey(pid), JSON.stringify(snapshot));
}

export function newSession(mock: MockDef, kind: SessionState['kind']): SessionState {
  const answers: SessionState['answers'] = {};
  for (const sec of mock.sections) for (const id of sec.questionIds) answers[id] = { status: 'unseen', choice: null, timeSec: 0 };
  const first = mock.sections[0];
  return {
    mock,
    kind,
    si: 0,
    qi: 0,
    answers,
    sectionEndsAt: Date.now() + first.minutes * 60_000,
    startedAt: Date.now(),
    sectionTimeUsed: [],
    finished: false,
  };
}

export function scoreSession(s: SessionState): TestResult {
  const sections: TestResult['sections'] = [];
  const answers: TestResult['answers'] = {};
  let totalScore = 0;
  let maxScore = 0;
  let attempted = 0;
  let correctTotal = 0;

  s.mock.sections.forEach((sec, i) => {
    let secAttempted = 0;
    let secCorrect = 0;
    let secWrong = 0;
    let secScore = 0;
    for (const qid of sec.questionIds) {
      const q = questionById.get(qid);
      const a = s.answers[qid];
      if (!q || !a) continue;
      const isAttempted = a.choice !== null;
      const isCorrect = isAttempted && a.choice === q.correct;
      if (isAttempted) {
        secAttempted++;
        if (isCorrect) {
          secCorrect++;
          secScore += sec.marksPerQuestion;
        } else {
          secWrong++;
          secScore -= sec.marksPerQuestion * sec.negativeFraction;
        }
      }
      answers[qid] = { choice: a.choice, correct: isCorrect, timeSec: a.timeSec, topic: q.topic, section: q.section };
    }
    const secMax = sec.questionIds.length * sec.marksPerQuestion;
    sections.push({
      name: sec.name,
      pool: sec.pool,
      attempted: secAttempted,
      correct: secCorrect,
      wrong: secWrong,
      score: Math.round(secScore * 100) / 100,
      maxScore: Math.round(secMax * 100) / 100,
      timeUsedSec: s.sectionTimeUsed[i] ?? 0,
    });
    totalScore += secScore;
    maxScore += secMax;
    attempted += secAttempted;
    correctTotal += secCorrect;
  });

  return {
    id: `r${Date.now().toString(36)}`,
    mockId: s.mock.id,
    mockName: s.mock.name,
    stage: s.mock.stage,
    kind: s.kind,
    finishedAt: Date.now(),
    totalScore: Math.round(totalScore * 100) / 100,
    maxScore: Math.round(maxScore * 100) / 100,
    accuracy: attempted ? correctTotal / attempted : 0,
    attempted,
    totalQuestions: s.mock.sections.reduce((n, sec) => n + sec.questionIds.length, 0),
    sections,
    answers,
  };
}

function nextStatus(cur: QStatus, kind: 'visit' | 'answer' | 'clear' | 'mark'): QStatus {
  switch (kind) {
    case 'visit':
      return cur === 'unseen' ? 'seen' : cur;
    case 'answer':
      return cur === 'marked' || cur === 'answeredMarked' ? 'answeredMarked' : 'answered';
    case 'clear':
      return cur === 'answeredMarked' || cur === 'marked' ? 'marked' : 'seen';
    case 'mark':
      return cur === 'answered' || cur === 'answeredMarked' ? 'answeredMarked' : 'marked';
  }
}

/**
 * Drives a live test session: 1s tick, per-question time accrual, sectional
 * auto-advance, persistence for resume. `timed=false` (practice) disables timers.
 */
export function useTestSession(pid: string, initial: SessionState, timed: boolean, onFinish: (r: TestResult) => void) {
  const [s, setS] = useState<SessionState>(initial);
  const [now, setNow] = useState(() => Date.now());
  const sRef = useRef(s);
  sRef.current = s;
  const finishedRef = useRef(false);

  const update = useCallback(
    (fn: (prev: SessionState) => SessionState) => {
      setS((prev) => {
        const next = fn(prev);
        persist(pid, next);
        return next;
      });
    },
    [pid],
  );

  const finish = useCallback(() => {
    if (finishedRef.current) return;
    finishedRef.current = true;
    const cur = sRef.current;
    const elapsed = Math.round((Date.now() - (cur.sectionEndsAt - cur.mock.sections[cur.si].minutes * 60_000)) / 1000);
    const done: SessionState = {
      ...cur,
      finished: true,
      sectionTimeUsed: [...cur.sectionTimeUsed, Math.min(elapsed, cur.mock.sections[cur.si].minutes * 60)],
    };
    clearSession(pid);
    onFinish(scoreSession(done));
  }, [onFinish, pid]);

  const submitSection = useCallback(() => {
    const cur = sRef.current;
    if (cur.si >= cur.mock.sections.length - 1) {
      finish();
      return;
    }
    update((prev) => {
      const secLen = prev.mock.sections[prev.si].minutes * 60;
      const usedSec = Math.min(secLen, Math.round((Date.now() - (prev.sectionEndsAt - secLen * 1000)) / 1000));
      const nextSec = prev.mock.sections[prev.si + 1];
      return {
        ...prev,
        si: prev.si + 1,
        qi: 0,
        sectionEndsAt: Date.now() + nextSec.minutes * 60_000,
        sectionTimeUsed: [...prev.sectionTimeUsed, usedSec],
      };
    });
  }, [update, finish]);

  // clock
  useEffect(() => {
    if (!timed) return;
    const t = setInterval(() => {
      setNow(Date.now());
      const cur = sRef.current;
      if (!cur.finished && Date.now() >= cur.sectionEndsAt) {
        if (cur.si >= cur.mock.sections.length - 1) finish();
        else submitSection();
      }
    }, 500);
    return () => clearInterval(t);
  }, [timed, finish, submitSection]);

  // per-question time accrual
  const lastTick = useRef(Date.now());
  useEffect(() => {
    const t = setInterval(() => {
      const cur = sRef.current;
      if (cur.finished) return;
      const dt = Math.round((Date.now() - lastTick.current) / 1000);
      lastTick.current = Date.now();
      if (dt <= 0 || dt > 10) return; // tab was hidden; don't attribute the gap
      const qid = cur.mock.sections[cur.si].questionIds[cur.qi];
      update((prev) => ({
        ...prev,
        answers: { ...prev.answers, [qid]: { ...prev.answers[qid], timeSec: prev.answers[qid].timeSec + dt } },
      }));
    }, 1000);
    return () => clearInterval(t);
  }, [update]);

  const currentSection = s.mock.sections[s.si];
  const currentQid = currentSection.questionIds[s.qi];

  // mark current as seen
  useEffect(() => {
    update((prev) => {
      const qid = prev.mock.sections[prev.si].questionIds[prev.qi];
      const a = prev.answers[qid];
      if (a.status !== 'unseen') return prev;
      return { ...prev, answers: { ...prev.answers, [qid]: { ...a, status: nextStatus(a.status, 'visit') } } };
    });
  }, [s.si, s.qi, update]);

  const api = useMemo(
    () => ({
      goto: (qi: number) => update((p) => ({ ...p, qi: Math.max(0, Math.min(qi, p.mock.sections[p.si].questionIds.length - 1)) })),
      next: () => update((p) => ({ ...p, qi: Math.min(p.qi + 1, p.mock.sections[p.si].questionIds.length - 1) })),
      prev: () => update((p) => ({ ...p, qi: Math.max(0, p.qi - 1) })),
      choose: (choice: number) =>
        update((p) => {
          const qid = p.mock.sections[p.si].questionIds[p.qi];
          const a = p.answers[qid];
          return { ...p, answers: { ...p.answers, [qid]: { ...a, choice, status: nextStatus(a.status, 'answer') } } };
        }),
      clearChoice: () =>
        update((p) => {
          const qid = p.mock.sections[p.si].questionIds[p.qi];
          const a = p.answers[qid];
          return { ...p, answers: { ...p.answers, [qid]: { ...a, choice: null, status: nextStatus(a.status, 'clear') } } };
        }),
      toggleMark: () =>
        update((p) => {
          const qid = p.mock.sections[p.si].questionIds[p.qi];
          const a = p.answers[qid];
          const st = a.status === 'marked' || a.status === 'answeredMarked'
            ? a.choice !== null ? 'answered' as QStatus : 'seen' as QStatus
            : nextStatus(a.status, 'mark');
          return { ...p, answers: { ...p.answers, [qid]: { ...a, status: st } } };
        }),
      submitSection,
      finish,
      switchSection: (si: number) => {
        // free navigation only in untimed practice
        if (timed) return;
        update((p) => ({ ...p, si: Math.max(0, Math.min(si, p.mock.sections.length - 1)), qi: 0 }));
      },
    }),
    [update, submitSection, finish, timed],
  );

  const remainingSec = Math.max(0, Math.round((s.sectionEndsAt - now) / 1000));
  return { s, currentSection, currentQid, remainingSec, ...api };
}

export function fmtClock(totalSec: number): string {
  const m = Math.floor(totalSec / 60);
  const sec = totalSec % 60;
  return `${String(m).padStart(2, '0')}:${String(sec).padStart(2, '0')}`;
}
