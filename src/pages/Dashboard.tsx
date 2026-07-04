import { motion } from 'framer-motion';
import { ArrowRight, BookOpenText, ClipboardList, Flame, History, Play, Target, Timer, TrendingUp, Zap } from 'lucide-react';
import { useMemo } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { TrendChart } from '../components/charts';
import { Button, Card, Chip, SectionTitle, Stat } from '../components/ui';
import { allQuestions, buildGeneratedMock, SECTION_META, topicName } from '../lib/data';
import { loadSession } from '../lib/engine';
import { computeStreak, dateKey, useApp } from '../lib/store';
import type { SectionId } from '../types';

export default function Dashboard() {
  const navigate = useNavigate();
  const { profile, state } = useApp();
  const saved = loadSession(profile.id);
  const streak = computeStreak(state);

  const mocks = state.results.filter((r) => r.kind === 'mock');
  const avgLast5 = mocks.length
    ? mocks.slice(-5).reduce((n, r) => n + (r.totalScore / r.maxScore) * 100, 0) / Math.min(5, mocks.length)
    : null;
  const todayFocus = state.pomodoro.find((p) => p.dateKey === dateKey())?.focusMinutes ?? 0;

  const weakTopics = useMemo(() => {
    return Object.entries(state.topicStats)
      .filter(([, v]) => v.attempted >= 4)
      .map(([slug, v]) => {
        const q = allQuestions.find((q) => q.topic === slug);
        return { slug, section: (q?.section ?? 'quant') as SectionId, accuracy: v.correct / v.attempted, attempted: v.attempted };
      })
      .sort((a, b) => a.accuracy - b.accuracy)
      .slice(0, 4);
  }, [state.topicStats]);

  const bankCounts = useMemo(() => {
    const counts = new Map<SectionId, number>();
    for (const q of allQuestions) counts.set(q.section, (counts.get(q.section) ?? 0) + 1);
    return counts;
  }, []);

  const hour = new Date().getHours();
  const greeting = hour < 12 ? 'Good morning' : hour < 17 ? 'Good afternoon' : 'Good evening';

  return (
    <div className="space-y-8">
      {/* hero */}
      <div className="relative overflow-hidden card p-6 md:p-8">
        <div className="absolute inset-0 grid-fade pointer-events-none" />
        <div className="relative">
          <motion.h1
            className="font-display font-bold text-2xl md:text-[28px] tracking-tight"
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
          >
            {greeting}, {profile.name.split(' ')[0]}
          </motion.h1>
          <motion.p className="text-ink-3 text-sm mt-1" initial={{ opacity: 0 }} animate={{ opacity: 1 }} transition={{ delay: 0.08 }}>
            SBI PO preparation — consistent daily reps beat cramming. Pick up where you left off.
          </motion.p>
          <motion.div className="flex flex-wrap gap-2.5 mt-5" initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.14 }}>
            {saved && !saved.finished ? (
              <Button onClick={() => navigate('/test')}>
                <History size={15} /> Resume {saved.mock.name}
              </Button>
            ) : (
              <Button onClick={() => navigate('/test', { state: { mock: buildGeneratedMock('prelims', 1), kind: 'mock' } })}>
                <Play size={15} /> Start Prelims Mock
              </Button>
            )}
            <Button variant="soft" onClick={() => navigate('/mocks')}>
              <Zap size={15} /> Quick Drill
            </Button>
            <Button variant="outline" onClick={() => navigate('/pomodoro')}>
              <Timer size={15} /> Focus Session
            </Button>
          </motion.div>
        </div>
      </div>

      {/* stats */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-3">
        <Stat label="Streak" value={<span className="flex items-center gap-1.5">{streak}<Flame size={18} className="text-warn" /></span>} sub="consecutive study days" />
        <Stat label="Mocks Taken" value={mocks.length} sub={mocks.length ? `last: ${new Date(mocks[mocks.length - 1].finishedAt).toLocaleDateString()}` : 'none yet'} />
        <Stat label="Avg Score (last 5)" value={avgLast5 !== null ? `${avgLast5.toFixed(0)}%` : '—'} tone={avgLast5 !== null && avgLast5 >= 60 ? 'teal' : undefined} />
        <Stat label="Focus Today" value={`${todayFocus}m`} sub="pomodoro minutes" />
      </div>

      <div className="grid lg:grid-cols-5 gap-6">
        {/* trend */}
        <Card className="p-5 lg:col-span-3">
          <SectionTitle
            title="Mock Score Trend"
            sub={mocks.length > 1 ? 'Percentage of maximum, most recent last' : 'Take mocks to see your curve'}
            right={<TrendingUp size={17} className="text-ink-3" />}
          />
          {mocks.length > 0 ? (
            <TrendChart
              points={mocks.map((r) => (r.totalScore / r.maxScore) * 100)}
              maxY={100}
              labels={mocks.map((r) => r.mockName)}
            />
          ) : (
            <div className="py-12 text-center text-sm text-ink-3">
              Your first mock unlocks the trend chart.
              <div className="mt-3">
                <Button size="sm" variant="soft" onClick={() => navigate('/mocks')}>
                  <ClipboardList size={14} /> Browse mocks
                </Button>
              </div>
            </div>
          )}
        </Card>

        {/* weak topics */}
        <Card className="p-5 lg:col-span-2">
          <SectionTitle title="Weak Topics" sub="Lowest accuracy, most urgent first" right={<Target size={17} className="text-ink-3" />} />
          {weakTopics.length ? (
            <div className="space-y-2.5">
              {weakTopics.map((t) => (
                <Link
                  key={t.slug}
                  to={`/practice?section=${t.section}&topic=${t.slug}`}
                  className="flex items-center gap-3 p-3 rounded-xl border border-line hover:border-line-strong hover:bg-raised transition-all group"
                >
                  <div className="flex-1 min-w-0">
                    <div className="text-sm font-semibold truncate">{topicName(t.section, t.slug)}</div>
                    <div className="text-[11px] text-ink-3">{SECTION_META[t.section].short} · {t.attempted} attempted</div>
                  </div>
                  <Chip tone={t.accuracy < 0.4 ? 'danger' : 'warn'}>{Math.round(t.accuracy * 100)}%</Chip>
                  <ArrowRight size={14} className="text-ink-3 group-hover:translate-x-0.5 transition-transform" />
                </Link>
              ))}
            </div>
          ) : (
            <p className="text-sm text-ink-3 py-8 text-center">Attempt a few questions and your weak spots will surface here.</p>
          )}
        </Card>
      </div>

      {/* bank status */}
      <Card className="p-5">
        <SectionTitle
          title="Question Bank"
          sub="Grows as book extraction lands"
          right={
            <Link to="/practice" className="text-xs font-semibold text-accent inline-flex items-center gap-1 hover:gap-1.5 transition-all">
              Practice <ArrowRight size={13} />
            </Link>
          }
        />
        <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
          {(Object.keys(SECTION_META) as SectionId[]).map((sec) => (
            <div key={sec} className="flex items-center gap-3 p-3 rounded-xl bg-sunken/60">
              <div className="w-9 h-9 rounded-lg bg-accent-soft text-accent flex items-center justify-center">
                <BookOpenText size={16} />
              </div>
              <div>
                <div className="font-display font-bold text-lg leading-none">{bankCounts.get(sec) ?? 0}</div>
                <div className="text-[11px] text-ink-3 mt-1">{SECTION_META[sec].short}</div>
              </div>
            </div>
          ))}
        </div>
      </Card>
    </div>
  );
}
