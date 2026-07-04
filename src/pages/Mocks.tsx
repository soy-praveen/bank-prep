import { motion } from 'framer-motion';
import { AlertTriangle, ClipboardList, History, Play, Timer, Zap } from 'lucide-react';
import { useMemo, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Button, Card, Chip, SectionTitle, Stat } from '../components/ui';
import { buildGeneratedMock, poolCoverage, sampleSection, stagePattern, SECTION_META } from '../lib/data';
import { loadSession } from '../lib/engine';
import { useApp } from '../lib/store';
import type { MockDef, SectionId } from '../types';

const DRILL_SIZES = [10, 15, 20, 25] as const;

export default function Mocks() {
  const navigate = useNavigate();
  const { profile, state } = useApp();
  const [stage, setStage] = useState<'prelims' | 'mains'>('prelims');
  const [drillSection, setDrillSection] = useState<SectionId>('quant');
  const [drillSize, setDrillSize] = useState<number>(15);

  const saved = loadSession(profile.id);
  const pattern = stagePattern(stage);
  const coverage = poolCoverage(stage);
  const shortfall = coverage.filter((c) => c.have < c.need);
  const attempts = state.results.filter((r) => r.kind === 'mock');

  const mocks = useMemo(() => [1, 2, 3, 4, 5].map((n) => buildGeneratedMock(stage, n)), [stage]);

  const startMock = (mock: MockDef) => navigate('/test', { state: { mock, kind: 'mock' } });

  const startDrill = () => {
    const seed = Date.now() % 100000;
    const ids = sampleSection(drillSection, stage, drillSize, seed);
    if (ids.length === 0) return;
    const mock: MockDef = {
      id: `drill-${drillSection}-${seed}`,
      name: `${SECTION_META[drillSection].short} Drill · ${ids.length}Q`,
      stage,
      description: 'Random timed sectional drill',
      sections: [
        {
          name: SECTION_META[drillSection].name,
          pool: drillSection,
          minutes: Math.ceil(ids.length * (drillSection === 'general' ? 0.6 : 1)),
          marksPerQuestion: 1,
          negativeFraction: 0.25,
          questionIds: ids,
        },
      ],
    };
    navigate('/test', { state: { mock, kind: 'drill' } });
  };

  return (
    <div className="space-y-8">
      {saved && !saved.finished && (
        <motion.div initial={{ opacity: 0, y: -8 }} animate={{ opacity: 1, y: 0 }}>
          <Card className="p-4 flex items-center gap-4 border-l-[3px] border-l-accent">
            <div className="w-10 h-10 rounded-xl bg-accent-soft text-accent flex items-center justify-center shrink-0">
              <History size={18} />
            </div>
            <div className="flex-1 min-w-0">
              <div className="font-semibold text-sm">Attempt in progress — {saved.mock.name}</div>
              <div className="text-xs text-ink-3">Section {saved.si + 1} of {saved.mock.sections.length} · your palette and answers are saved</div>
            </div>
            <Button size="sm" onClick={() => navigate('/test')}>
              <Play size={14} /> Resume
            </Button>
          </Card>
        </motion.div>
      )}

      {/* stage switch + pattern summary */}
      <div>
        <div className="flex items-center gap-2 mb-5">
          {(['prelims', 'mains'] as const).map((st) => (
            <button
              key={st}
              onClick={() => setStage(st)}
              className={`relative px-5 py-2 rounded-xl text-sm font-semibold transition-colors cursor-pointer ${
                stage === st ? 'text-white' : 'text-ink-2 hover:bg-sunken'
              }`}
            >
              {stage === st && (
                <motion.div layoutId="stage-pill" className="absolute inset-0 bg-accent rounded-xl" transition={{ type: 'spring', stiffness: 400, damping: 32 }} />
              )}
              <span className="relative z-10">{st === 'prelims' ? 'Prelims' : 'Mains'}</span>
            </button>
          ))}
          <Chip tone="accent" className="ml-2">SBI PO 2025-26 pattern</Chip>
        </div>

        <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
          <Stat label="Questions" value={pattern.totalQuestions} />
          <Stat label="Marks" value={pattern.totalMarks} />
          <Stat label="Duration" value={`${pattern.totalMinutes} min`} sub={pattern.sectionalTiming ? 'sectional timers' : undefined} />
          <Stat label="Negative" value="1/4 mark" sub="per wrong answer" />
        </div>
      </div>

      {shortfall.length > 0 && (
        <Card className="p-4 flex items-start gap-3 border-l-[3px] border-l-warn">
          <AlertTriangle size={17} className="text-warn shrink-0 mt-0.5" />
          <div className="text-sm text-ink-2">
            <span className="font-semibold text-ink">Question pool is still growing.</span>{' '}
            {shortfall.map((c) => `${c.name} has ${c.have}/${c.need}`).join(', ')} — mocks fill what they can and will reach full length
            as the extracted book questions land. Drills below always work.
          </div>
        </Card>
      )}

      {/* full mocks */}
      <div>
        <SectionTitle title="Full Mock Tests" sub="Exam-faithful: section order, sectional timers, real marking scheme" />
        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-4">
          {mocks.map((mock, i) => {
            const attempted = attempts.filter((a) => a.mockId === mock.id);
            const best = attempted.length ? Math.max(...attempted.map((a) => a.totalScore)) : null;
            const total = mock.sections.reduce((n, s) => n + s.questionIds.length, 0);
            return (
              <motion.div key={mock.id} initial={{ opacity: 0, y: 14 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: i * 0.05 }}>
                <Card hover className="p-5 flex flex-col gap-3 h-full">
                  <div className="flex items-center justify-between">
                    <div className="w-9 h-9 rounded-xl bg-accent-soft text-accent flex items-center justify-center">
                      <ClipboardList size={17} />
                    </div>
                    {best !== null && <Chip tone="teal">Best {best.toFixed(1)}</Chip>}
                  </div>
                  <div>
                    <div className="font-display font-semibold">{mock.name}</div>
                    <div className="text-xs text-ink-3 mt-1">
                      {total} questions · {mock.sections.reduce((n, s) => n + s.minutes, 0)} min
                      {attempted.length > 0 && ` · ${attempted.length} attempt${attempted.length > 1 ? 's' : ''}`}
                    </div>
                  </div>
                  <div className="mt-auto pt-2">
                    <Button size="sm" onClick={() => startMock(mock)} className="w-full">
                      <Play size={14} /> Start
                    </Button>
                  </div>
                </Card>
              </motion.div>
            );
          })}
        </div>
      </div>

      {/* sectional drill builder */}
      <div>
        <SectionTitle title="Sectional Drill" sub="A fast randomized set — different questions every run" />
        <Card className="p-5">
          <div className="flex flex-wrap items-center gap-x-6 gap-y-4">
            <div>
              <div className="text-[11px] font-bold uppercase tracking-wider text-ink-3 mb-2">Section</div>
              <div className="flex gap-1.5 flex-wrap">
                {(Object.keys(SECTION_META) as SectionId[]).map((sec) => (
                  <button
                    key={sec}
                    onClick={() => setDrillSection(sec)}
                    className={`px-3.5 py-1.5 rounded-lg text-xs font-semibold transition-all cursor-pointer ${
                      drillSection === sec ? 'bg-accent text-white shadow-sm' : 'bg-sunken text-ink-2 hover:text-ink'
                    }`}
                  >
                    {SECTION_META[sec].short}
                  </button>
                ))}
              </div>
            </div>
            <div>
              <div className="text-[11px] font-bold uppercase tracking-wider text-ink-3 mb-2">Questions</div>
              <div className="flex gap-1.5">
                {DRILL_SIZES.map((n) => (
                  <button
                    key={n}
                    onClick={() => setDrillSize(n)}
                    className={`px-3.5 py-1.5 rounded-lg text-xs font-semibold transition-all cursor-pointer ${
                      drillSize === n ? 'bg-accent text-white shadow-sm' : 'bg-sunken text-ink-2 hover:text-ink'
                    }`}
                  >
                    {n}
                  </button>
                ))}
              </div>
            </div>
            <div className="ml-auto flex items-center gap-3">
              <div className="text-xs text-ink-3 flex items-center gap-1.5">
                <Timer size={13} /> ~{Math.ceil(drillSize * (drillSection === 'general' ? 0.6 : 1))} min
              </div>
              <Button onClick={startDrill}>
                <Zap size={15} /> Start Drill
              </Button>
            </div>
          </div>
        </Card>
      </div>
    </div>
  );
}
