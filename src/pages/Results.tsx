import { motion } from 'framer-motion';
import { ArrowLeft, CheckCircle2, ChevronDown, Circle, Target, Timer, XCircle } from 'lucide-react';
import { useMemo, useState } from 'react';
import { Link, useNavigate, useParams } from 'react-router-dom';
import { TopicBars, TrendChart } from '../components/charts';
import { Button, Card, Chip, CountUp, Ring, SectionTitle } from '../components/ui';
import { questionById, setById, topicName } from '../lib/data';
import { fmtClock } from '../lib/engine';
import { Md } from '../lib/md';
import { useApp } from '../lib/store';

type Filter = 'all' | 'wrong' | 'skipped';

export default function Results() {
  const { rid } = useParams();
  const navigate = useNavigate();
  const { state } = useApp();
  const [filter, setFilter] = useState<Filter>('all');
  const [openQ, setOpenQ] = useState<string | null>(null);

  const result = state.results.find((r) => r.id === rid);
  const history = useMemo(
    () => (result ? state.results.filter((r) => r.stage === result.stage && r.kind === result.kind) : []),
    [state.results, result],
  );

  const topicRows = useMemo(() => {
    if (!result) return [];
    const byTopic = new Map<string, { name: string; attempted: number; correct: number }>();
    for (const a of Object.values(result.answers)) {
      if (a.choice === null) continue;
      const key = a.topic;
      const cur = byTopic.get(key) ?? { name: topicName(a.section, a.topic), attempted: 0, correct: 0 };
      cur.attempted++;
      if (a.correct) cur.correct++;
      byTopic.set(key, cur);
    }
    return [...byTopic.values()]
      .sort((a, b) => a.correct / a.attempted - b.correct / b.attempted)
      .map((t) => ({ name: t.name, fraction: t.correct / t.attempted, detail: `${t.correct}/${t.attempted}` }));
  }, [result]);

  if (!result) {
    return (
      <div className="text-center py-20">
        <p className="text-ink-3">Result not found for this profile.</p>
        <Button className="mt-4" onClick={() => navigate('/mocks')}>Back to Mocks</Button>
      </div>
    );
  }

  const pct = result.maxScore ? result.totalScore / result.maxScore : 0;
  const skipped = result.totalQuestions - result.attempted;
  const totalTime = result.sections.reduce((n, s) => n + s.timeUsedSec, 0);

  const reviewIds = Object.keys(result.answers).filter((qid) => {
    const a = result.answers[qid];
    if (filter === 'wrong') return a.choice !== null && !a.correct;
    if (filter === 'skipped') return a.choice === null;
    return true;
  });

  return (
    <div className="space-y-8">
      <Link to="/mocks" className="inline-flex items-center gap-1.5 text-sm text-ink-3 hover:text-ink transition-colors">
        <ArrowLeft size={15} /> Mock Tests
      </Link>

      {/* score hero */}
      <Card className="p-6 md:p-8">
        <div className="flex flex-col md:flex-row items-center gap-8">
          <Ring fraction={Math.max(0, pct)} size={150} stroke={10} tone={pct >= 0.6 ? 'teal' : pct >= 0.4 ? 'warn' : 'danger'}>
            <div className="font-display font-bold text-3xl">
              <CountUp value={result.totalScore} decimals={1} />
            </div>
            <div className="text-[11px] text-ink-3">of {result.maxScore}</div>
          </Ring>
          <div className="flex-1 w-full">
            <div className="flex items-center gap-2 flex-wrap justify-center md:justify-start">
              <h1 className="font-display font-bold text-xl">{result.mockName}</h1>
              <Chip tone="accent">{result.stage}</Chip>
              <Chip>{new Date(result.finishedAt).toLocaleString()}</Chip>
            </div>
            <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 mt-5">
              {[
                { label: 'Accuracy', value: `${Math.round(result.accuracy * 100)}%`, icon: Target },
                { label: 'Attempted', value: `${result.attempted}/${result.totalQuestions}`, icon: CheckCircle2 },
                { label: 'Skipped', value: String(skipped), icon: Circle },
                { label: 'Time Used', value: fmtClock(totalTime), icon: Timer },
              ].map(({ label, value, icon: Icon }) => (
                <div key={label} className="text-center md:text-left">
                  <div className="text-[10px] font-bold uppercase tracking-[0.1em] text-ink-3 flex items-center gap-1 justify-center md:justify-start">
                    <Icon size={11} /> {label}
                  </div>
                  <div className="font-display font-bold text-lg mt-0.5">{value}</div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </Card>

      {/* sectional breakdown */}
      <div>
        <SectionTitle title="Sectional Performance" />
        <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-4">
          {result.sections.map((sec, i) => {
            const secPct = sec.maxScore ? sec.score / sec.maxScore : 0;
            return (
              <motion.div key={sec.name} initial={{ opacity: 0, y: 12 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: i * 0.06 }}>
                <Card className="p-4 h-full">
                  <div className="text-xs font-semibold text-ink-2 truncate" title={sec.name}>{sec.name}</div>
                  <div className="font-display font-bold text-2xl mt-1.5">
                    {sec.score.toFixed(1)} <span className="text-sm text-ink-3 font-medium">/ {sec.maxScore}</span>
                  </div>
                  <div className="h-1.5 rounded-full bg-sunken overflow-hidden mt-2.5">
                    <div
                      className="h-full rounded-full"
                      style={{
                        width: `${Math.max(0, secPct) * 100}%`,
                        background: secPct >= 0.6 ? 'var(--teal)' : secPct >= 0.4 ? 'var(--warn)' : 'var(--danger)',
                        transition: 'width 700ms cubic-bezier(0.22,1,0.36,1)',
                      }}
                    />
                  </div>
                  <div className="flex justify-between text-[11px] text-ink-3 mt-2.5">
                    <span className="text-teal font-semibold">{sec.correct} right</span>
                    <span className="text-danger font-semibold">{sec.wrong} wrong</span>
                    <span>{fmtClock(sec.timeUsedSec)}</span>
                  </div>
                </Card>
              </motion.div>
            );
          })}
        </div>
      </div>

      <div className="grid lg:grid-cols-2 gap-6">
        {history.length > 1 && (
          <Card className="p-5">
            <SectionTitle title="Score Trend" sub={`Across your ${history.length} ${result.kind} attempts`} />
            <TrendChart
              points={history.map((h) => h.totalScore)}
              maxY={result.maxScore}
              labels={history.map((h) => new Date(h.finishedAt).toLocaleDateString())}
            />
          </Card>
        )}
        {topicRows.length > 0 && (
          <Card className="p-5">
            <SectionTitle title="Topic Accuracy" sub="Weakest first — these are your next practice targets" />
            <TopicBars rows={topicRows.slice(0, 8)} />
          </Card>
        )}
      </div>

      {/* solutions review */}
      <div>
        <SectionTitle
          title="Solutions Review"
          right={
            <div className="flex gap-1.5">
              {(['all', 'wrong', 'skipped'] as Filter[]).map((f) => (
                <button
                  key={f}
                  onClick={() => setFilter(f)}
                  className={`px-3 py-1.5 rounded-lg text-xs font-semibold capitalize transition-colors cursor-pointer ${
                    filter === f ? 'bg-accent text-white' : 'bg-sunken text-ink-2 hover:text-ink'
                  }`}
                >
                  {f}
                </button>
              ))}
            </div>
          }
        />
        <div className="space-y-3">
          {reviewIds.map((qid, idx) => {
            const q = questionById.get(qid);
            const a = result.answers[qid];
            if (!q) return null;
            const open = openQ === qid;
            const qSet = q.setId ? setById.get(q.setId) : undefined;
            return (
              <Card key={qid} className="overflow-hidden">
                <button
                  onClick={() => setOpenQ(open ? null : qid)}
                  className="w-full flex items-center gap-3 p-4 text-left cursor-pointer hover:bg-raised transition-colors"
                >
                  {a.choice === null ? (
                    <Circle size={18} className="text-ink-3 shrink-0" />
                  ) : a.correct ? (
                    <CheckCircle2 size={18} className="text-teal shrink-0" />
                  ) : (
                    <XCircle size={18} className="text-danger shrink-0" />
                  )}
                  <span className="text-sm font-medium flex-1 truncate">
                    {idx + 1}. {q.question.replace(/\*\*/g, '').split('\n')[0]}
                  </span>
                  <Chip className="hidden sm:inline-flex">{topicName(q.section, q.topic)}</Chip>
                  <span className="text-[11px] text-ink-3 tabular-nums shrink-0">{fmtClock(a.timeSec)}</span>
                  <ChevronDown size={16} className={`text-ink-3 transition-transform duration-200 shrink-0 ${open ? 'rotate-180' : ''}`} />
                </button>
                {open && (
                  <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} className="px-5 pb-5 border-t border-line pt-4">
                    {qSet && (
                      <div className="card p-4 mb-3 bg-raised">
                        <div className="text-[10px] font-bold uppercase tracking-wider text-ink-3 mb-1.5">{qSet.title}</div>
                        <Md text={qSet.context} className="text-sm text-ink-2" />
                      </div>
                    )}
                    <Md text={q.question} className="text-[15px] font-medium mb-4" />
                    <div className="space-y-2">
                      {q.options.map((opt, i) => (
                        <div
                          key={i}
                          className={`flex items-start gap-2.5 p-2.5 rounded-lg text-sm border ${
                            i === q.correct
                              ? 'border-teal bg-teal-soft'
                              : i === a.choice
                                ? 'border-danger bg-danger-soft'
                                : 'border-transparent'
                          }`}
                        >
                          <span className="font-bold text-xs mt-0.5 w-4">{String.fromCharCode(97 + i)})</span>
                          <Md text={opt} className="flex-1" />
                          {i === q.correct && <Chip tone="teal">Correct</Chip>}
                          {i === a.choice && i !== q.correct && <Chip tone="danger">Your pick</Chip>}
                        </div>
                      ))}
                    </div>
                    <div className="card p-4 mt-3 border-l-[3px] border-l-accent">
                      <div className="text-[10px] font-bold uppercase tracking-wider text-accent mb-1.5">Explanation</div>
                      <Md text={q.explanation} className="text-sm text-ink-2" />
                    </div>
                  </motion.div>
                )}
              </Card>
            );
          })}
          {reviewIds.length === 0 && <p className="text-sm text-ink-3 py-6 text-center">Nothing in this filter.</p>}
        </div>
      </div>
    </div>
  );
}
