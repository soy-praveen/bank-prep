import { AnimatePresence, motion } from 'framer-motion';
import {
  AlarmClock,
  ArrowLeft,
  ArrowRight,
  Bookmark,
  CheckCircle2,
  ChevronLeft,
  Eraser,
  Flag,
  Landmark,
  LogOut,
  XCircle,
} from 'lucide-react';
import { useCallback, useMemo, useState } from 'react';
import { useLocation, useNavigate } from 'react-router-dom';
import { Button, Chip, Modal } from '../components/ui';
import { Md } from '../lib/md';
import { clearSession, fmtClock, loadSession, newSession, useTestSession, type SessionState } from '../lib/engine';
import { questionById, setById, topicName } from '../lib/data';
import { useApp } from '../lib/store';
import type { MockDef, QStatus } from '../types';

const STATUS_STYLE: Record<QStatus, string> = {
  unseen: 'bg-sunken text-ink-3 border border-line',
  seen: 'bg-danger text-white',
  answered: 'bg-teal text-white',
  marked: 'bg-violet text-white',
  answeredMarked: 'bg-violet text-white ring-2 ring-teal ring-offset-1 ring-offset-surface',
};

function Palette({
  s,
  onGoto,
}: {
  s: SessionState;
  onGoto: (qi: number) => void;
}) {
  const sec = s.mock.sections[s.si];
  const counts = useMemo(() => {
    const c: Record<QStatus, number> = { unseen: 0, seen: 0, answered: 0, marked: 0, answeredMarked: 0 };
    for (const qid of sec.questionIds) c[s.answers[qid].status]++;
    return c;
  }, [s, sec]);

  return (
    <div className="flex flex-col gap-4">
      <div className="grid grid-cols-5 gap-2">
        {sec.questionIds.map((qid, i) => (
          <button
            key={qid}
            onClick={() => onGoto(i)}
            className={`h-9 rounded-lg text-xs font-bold transition-all duration-150 cursor-pointer hover:scale-105 ${STATUS_STYLE[s.answers[qid].status]} ${
              i === s.qi ? 'outline outline-2 outline-accent outline-offset-2' : ''
            }`}
          >
            {i + 1}
          </button>
        ))}
      </div>
      <div className="space-y-1.5 text-[11px] text-ink-2">
        <div className="flex items-center gap-2"><span className="w-3 h-3 rounded bg-teal inline-block" /> Answered ({counts.answered + counts.answeredMarked})</div>
        <div className="flex items-center gap-2"><span className="w-3 h-3 rounded bg-danger inline-block" /> Seen, not answered ({counts.seen})</div>
        <div className="flex items-center gap-2"><span className="w-3 h-3 rounded bg-violet inline-block" /> Marked for review ({counts.marked + counts.answeredMarked})</div>
        <div className="flex items-center gap-2"><span className="w-3 h-3 rounded bg-sunken border border-line inline-block" /> Not visited ({counts.unseen})</div>
      </div>
    </div>
  );
}

function PlayerInner({ initial, timed, instantFeedback }: { initial: SessionState; timed: boolean; instantFeedback: boolean }) {
  const navigate = useNavigate();
  const { profile, recordResult } = useApp();
  const [confirmSubmit, setConfirmSubmit] = useState(false);
  const [confirmQuit, setConfirmQuit] = useState(false);
  const [revealed, setRevealed] = useState<Record<string, boolean>>({});

  const onFinish = useCallback(
    (r: ReturnType<typeof import('../lib/engine').scoreSession>) => {
      recordResult(r);
      navigate(`/results/${r.id}`, { replace: true });
    },
    [recordResult, navigate],
  );

  const t = useTestSession(profile.id, initial, timed, onFinish);
  const { s, currentSection, currentQid, remainingSec } = t;
  const q = questionById.get(currentQid)!;
  const qSet = q.setId ? setById.get(q.setId) : undefined;
  const attempt = s.answers[currentQid];
  const isLastSection = s.si === s.mock.sections.length - 1;
  const isLastQ = s.qi === currentSection.questionIds.length - 1;
  const showAnswer = instantFeedback && revealed[currentQid];
  const lowTime = timed && remainingSec <= 120;

  const choose = (i: number) => {
    if (showAnswer) return;
    t.choose(i);
    if (instantFeedback) setRevealed((r) => ({ ...r, [currentQid]: true }));
  };

  const submitLabel = isLastSection ? 'Submit Test' : 'Submit Section';

  return (
    <div className="min-h-screen flex flex-col bg-bg">
      {/* header */}
      <header className="h-14 shrink-0 border-b border-line bg-surface flex items-center gap-3 px-4 md:px-6">
        <div className="w-7 h-7 rounded-lg bg-accent-soft text-accent flex items-center justify-center shrink-0">
          <Landmark size={15} />
        </div>
        <div className="min-w-0">
          <div className="font-display font-semibold text-sm truncate">{s.mock.name}</div>
          <div className="text-[10px] text-ink-3 uppercase tracking-wider">{s.kind === 'practice' ? 'Practice mode' : 'Exam mode'}</div>
        </div>

        {/* section tabs */}
        <div className="hidden lg:flex items-center gap-1 ml-6">
          {s.mock.sections.map((sec, i) => (
            <button
              key={sec.name}
              onClick={() => t.switchSection(i)}
              disabled={timed}
              className={`px-3 py-1.5 rounded-lg text-xs font-semibold transition-colors ${
                i === s.si ? 'bg-accent text-white' : timed ? 'text-ink-3' : 'text-ink-2 hover:bg-sunken cursor-pointer'
              } ${timed && i !== s.si ? 'opacity-50' : ''}`}
            >
              {sec.name}
            </button>
          ))}
        </div>

        <div className="ml-auto flex items-center gap-3">
          {timed && (
            <div
              className={`flex items-center gap-2 px-3.5 py-1.5 rounded-full font-display font-bold text-sm tabular-nums transition-colors ${
                lowTime ? 'bg-danger-soft text-danger animate-pulse' : 'bg-sunken text-ink'
              }`}
            >
              <AlarmClock size={14} />
              {fmtClock(remainingSec)}
            </div>
          )}
          <Button variant="soft" size="sm" onClick={() => setConfirmSubmit(true)}>
            {submitLabel}
          </Button>
          <button onClick={() => setConfirmQuit(true)} className="text-ink-3 hover:text-danger transition-colors cursor-pointer" aria-label="Exit test">
            <LogOut size={17} />
          </button>
        </div>
      </header>

      {/* body */}
      <div className="flex-1 flex min-h-0">
        <main className="flex-1 min-w-0 overflow-y-auto">
          <div className="max-w-3xl mx-auto px-4 md:px-8 py-6">
            <div className="flex items-center gap-2 flex-wrap mb-4">
              <Chip tone="accent">Q {s.qi + 1} / {currentSection.questionIds.length}</Chip>
              <Chip>{topicName(q.section, q.topic)}</Chip>
              <Chip tone={q.difficulty === 1 ? 'teal' : q.difficulty === 2 ? 'warn' : 'danger'}>
                {q.difficulty === 1 ? 'Easy' : q.difficulty === 2 ? 'Moderate' : 'Hard'}
              </Chip>
              {timed && (
                <Chip tone="neutral" className="ml-auto">
                  +{currentSection.marksPerQuestion} / -{(currentSection.marksPerQuestion * currentSection.negativeFraction).toFixed(2)}
                </Chip>
              )}
            </div>

            <AnimatePresence mode="wait">
              <motion.div
                key={currentQid}
                initial={{ opacity: 0, x: 14 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: -10 }}
                transition={{ duration: 0.18, ease: 'easeOut' }}
              >
                {qSet && (
                  <div className="card p-5 mb-4 bg-raised">
                    <div className="text-[10px] font-bold uppercase tracking-[0.1em] text-ink-3 mb-2">{qSet.title}</div>
                    <Md text={qSet.context} className="text-[15px] leading-relaxed text-ink-2" />
                  </div>
                )}

                <Md text={q.question} className="text-[16px] leading-relaxed font-medium mb-5" />

                <div className="space-y-2.5">
                  {q.options.map((opt, i) => {
                    const chosen = attempt.choice === i;
                    const isCorrect = showAnswer && i === q.correct;
                    const isWrongChoice = showAnswer && chosen && i !== q.correct;
                    return (
                      <button
                        key={i}
                        onClick={() => choose(i)}
                        className={`w-full text-left flex items-start gap-3 p-3.5 rounded-xl border transition-all duration-150 cursor-pointer ${
                          isCorrect
                            ? 'border-teal bg-teal-soft'
                            : isWrongChoice
                              ? 'border-danger bg-danger-soft'
                              : chosen
                                ? 'border-accent bg-accent-soft'
                                : 'border-line bg-surface hover:border-line-strong hover:bg-raised'
                        }`}
                      >
                        <span
                          className={`w-6 h-6 rounded-full border flex items-center justify-center text-[11px] font-bold shrink-0 mt-0.5 transition-colors ${
                            isCorrect
                              ? 'bg-teal border-teal text-white'
                              : isWrongChoice
                                ? 'bg-danger border-danger text-white'
                                : chosen
                                  ? 'bg-accent border-accent text-white'
                                  : 'border-line-strong text-ink-3'
                          }`}
                        >
                          {String.fromCharCode(97 + i)}
                        </span>
                        <Md text={opt} className="text-[14.5px] leading-relaxed flex-1" />
                        {isCorrect && <CheckCircle2 size={18} className="text-teal shrink-0 mt-1" />}
                        {isWrongChoice && <XCircle size={18} className="text-danger shrink-0 mt-1" />}
                      </button>
                    );
                  })}
                </div>

                <AnimatePresence>
                  {showAnswer && (
                    <motion.div
                      initial={{ opacity: 0, height: 0 }}
                      animate={{ opacity: 1, height: 'auto' }}
                      exit={{ opacity: 0, height: 0 }}
                      className="overflow-hidden"
                    >
                      <div className="card p-5 mt-4 border-l-[3px] border-l-teal">
                        <div className="text-[10px] font-bold uppercase tracking-[0.1em] text-teal mb-1.5">Explanation</div>
                        <Md text={q.explanation} className="text-sm leading-relaxed text-ink-2" />
                      </div>
                    </motion.div>
                  )}
                </AnimatePresence>
              </motion.div>
            </AnimatePresence>

            {/* actions */}
            <div className="flex items-center gap-2 flex-wrap mt-7 pb-10">
              <Button variant="outline" size="sm" onClick={t.prev} disabled={s.qi === 0}>
                <ArrowLeft size={14} /> Previous
              </Button>
              <Button variant="outline" size="sm" onClick={t.clearChoice} disabled={attempt.choice === null || !!showAnswer}>
                <Eraser size={14} /> Clear
              </Button>
              <Button variant="outline" size="sm" onClick={() => { t.toggleMark(); if (!isLastQ) t.next(); }}>
                <Flag size={14} /> Mark & Next
              </Button>
              <div className="ml-auto">
                {isLastQ ? (
                  <Button onClick={() => setConfirmSubmit(true)}>{submitLabel}</Button>
                ) : (
                  <Button onClick={t.next}>
                    Save & Next <ArrowRight size={15} />
                  </Button>
                )}
              </div>
            </div>
          </div>
        </main>

        {/* palette rail */}
        <aside className="hidden md:block w-64 shrink-0 border-l border-line bg-surface/60 overflow-y-auto p-4">
          <div className="text-[10px] font-bold uppercase tracking-[0.1em] text-ink-3 mb-3">{currentSection.name}</div>
          <Palette s={s} onGoto={t.goto} />
          <div className="mt-5 pt-4 border-t border-line text-[11px] text-ink-3 leading-relaxed">
            <Bookmark size={12} className="inline mr-1" />
            Time on this question: {fmtClock(attempt.timeSec)}
          </div>
        </aside>
      </div>

      {/* submit confirmation */}
      <Modal open={confirmSubmit} onClose={() => setConfirmSubmit(false)} title={isLastSection ? 'Submit test?' : `Submit ${currentSection.name}?`}>
        <SubmitSummary s={s} />
        <p className="text-xs text-ink-3 mt-3">
          {isLastSection
            ? 'This ends the test and computes your score.'
            : timed
              ? 'You cannot return to this section afterwards — just like the real exam.'
              : 'You can still switch sections freely in practice mode.'}
        </p>
        <div className="flex gap-2 justify-end mt-5">
          <Button variant="ghost" onClick={() => setConfirmSubmit(false)}>Keep going</Button>
          <Button
            onClick={() => {
              setConfirmSubmit(false);
              if (isLastSection) t.finish();
              else t.submitSection();
            }}
          >
            {submitLabel}
          </Button>
        </div>
      </Modal>

      {/* quit confirmation */}
      <Modal open={confirmQuit} onClose={() => setConfirmQuit(false)} title="Leave the test?">
        <p className="text-sm text-ink-2">
          Your progress is saved locally — you can resume this attempt from the Mock Tests page. Leaving does not submit it.
        </p>
        <div className="flex gap-2 justify-end mt-5">
          <Button variant="ghost" onClick={() => setConfirmQuit(false)}>Stay</Button>
          <Button variant="danger" onClick={() => navigate('/mocks')}>
            <ChevronLeft size={14} /> Leave (resume later)
          </Button>
          <Button
            variant="danger"
            onClick={() => {
              clearSession(profile.id);
              navigate('/mocks');
            }}
          >
            Discard attempt
          </Button>
        </div>
      </Modal>
    </div>
  );
}

function SubmitSummary({ s }: { s: SessionState }) {
  const sec = s.mock.sections[s.si];
  const counts = { answered: 0, marked: 0, blank: 0 };
  for (const qid of sec.questionIds) {
    const a = s.answers[qid];
    if (a.choice !== null) counts.answered++;
    else counts.blank++;
    if (a.status === 'marked' || a.status === 'answeredMarked') counts.marked++;
  }
  return (
    <div className="grid grid-cols-3 gap-2 text-center">
      <div className="card p-3">
        <div className="font-display font-bold text-xl text-teal">{counts.answered}</div>
        <div className="text-[11px] text-ink-3">Answered</div>
      </div>
      <div className="card p-3">
        <div className="font-display font-bold text-xl text-violet">{counts.marked}</div>
        <div className="text-[11px] text-ink-3">Marked</div>
      </div>
      <div className="card p-3">
        <div className="font-display font-bold text-xl text-danger">{counts.blank}</div>
        <div className="text-[11px] text-ink-3">Unanswered</div>
      </div>
    </div>
  );
}

export default function TestPlayer() {
  const location = useLocation();
  const navigate = useNavigate();
  const { profile } = useApp();

  // A new test arrives via navigation state; otherwise resume the saved session.
  const init = useMemo(() => {
    const nav = location.state as { mock?: MockDef; kind?: 'mock' | 'drill' | 'practice' } | null;
    if (nav?.mock) {
      const kind = nav.kind ?? 'mock';
      return { session: newSession(nav.mock, kind), kind };
    }
    const saved = loadSession(profile.id);
    if (saved && !saved.finished) {
      // restart the clock for the current section from its remaining time snapshot
      return { session: saved, kind: saved.kind };
    }
    return null;
  }, [location.state, profile.id]);

  if (!init) {
    navigate('/mocks', { replace: true });
    return null;
  }

  const timed = init.kind !== 'practice';
  return <PlayerInner initial={init.session} timed={timed} instantFeedback={init.kind === 'practice'} />;
}
