import { motion } from 'framer-motion';
import { GraduationCap, Play, Timer } from 'lucide-react';
import { useMemo, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { Button, Card, Chip, SectionTitle } from '../components/ui';
import { bankTopics, questionsFor, SECTION_META } from '../lib/data';
import { useApp } from '../lib/store';
import type { MockDef, SectionId } from '../types';

function shuffleTake<T>(arr: T[], n: number): T[] {
  const a = [...arr];
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a.slice(0, n);
}

export default function Practice() {
  const navigate = useNavigate();
  const [params] = useSearchParams();
  const { state } = useApp();
  const [section, setSection] = useState<SectionId>((params.get('section') as SectionId) ?? 'quant');
  const highlight = params.get('topic');

  const topics = useMemo(() => bankTopics(section), [section]);

  const start = (topic: string, kind: 'practice' | 'drill') => {
    // keep whole sets together for practice by sampling then re-expanding set members
    const pool = questionsFor(section, { topic });
    const seedQs = shuffleTake(pool, 12);
    const withSets = new Set<string>();
    for (const q of seedQs) {
      if (q.setId) for (const m of pool.filter((p) => p.setId === q.setId)) withSets.add(m.id);
      else withSets.add(q.id);
    }
    const ids = [...withSets].slice(0, 15);
    if (!ids.length) return;
    const def: MockDef = {
      id: `${kind}-${topic}-${Date.now() % 100000}`,
      name: `${topics.find((t) => t.slug === topic)?.name ?? topic} · ${kind === 'practice' ? 'Practice' : 'Drill'}`,
      stage: 'prelims',
      description: '',
      sections: [
        {
          name: SECTION_META[section].name,
          pool: section,
          minutes: kind === 'drill' ? Math.ceil(ids.length) : 999,
          marksPerQuestion: 1,
          negativeFraction: kind === 'drill' ? 0.25 : 0,
          questionIds: ids,
        },
      ],
    };
    navigate('/test', { state: { mock: def, kind } });
  };

  return (
    <div className="space-y-6">
      <div className="flex gap-1.5 flex-wrap">
        {(Object.keys(SECTION_META) as SectionId[]).map((sec) => (
          <button
            key={sec}
            onClick={() => setSection(sec)}
            className={`relative px-4 py-2 rounded-xl text-sm font-semibold transition-colors cursor-pointer ${
              section === sec ? 'text-white' : 'text-ink-2 hover:bg-sunken'
            }`}
          >
            {section === sec && (
              <motion.div layoutId="practice-pill" className="absolute inset-0 bg-accent rounded-xl" transition={{ type: 'spring', stiffness: 400, damping: 32 }} />
            )}
            <span className="relative z-10">{SECTION_META[sec].name}</span>
          </button>
        ))}
      </div>

      <SectionTitle
        title="Practice by Topic"
        sub="Practice mode shows the solution after every answer; drills are timed with negative marking"
      />

      <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-4">
        {topics.map((t, i) => {
          const stats = state.topicStats[t.slug];
          const acc = stats && stats.attempted > 0 ? stats.correct / stats.attempted : null;
          return (
            <motion.div
              key={t.slug}
              initial={{ opacity: 0, y: 12 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: Math.min(i * 0.04, 0.3) }}
            >
              <Card
                className={`p-5 h-full flex flex-col gap-3 ${highlight === t.slug ? 'border-accent shadow-[0_0_0_3px_var(--accent-soft)]' : ''}`}
                hover
              >
                <div className="flex items-start justify-between gap-2">
                  <div className="font-semibold text-[15px] leading-snug">{t.name}</div>
                  {acc !== null && (
                    <Chip tone={acc >= 0.75 ? 'teal' : acc >= 0.5 ? 'warn' : 'danger'}>{Math.round(acc * 100)}%</Chip>
                  )}
                </div>
                <div className="text-xs text-ink-3">
                  {t.count} question{t.count > 1 ? 's' : ''} in bank
                  {stats ? ` · ${stats.attempted} attempted` : ''}
                </div>
                <div className="mt-auto flex gap-2 pt-1">
                  <Button size="sm" variant="soft" className="flex-1" onClick={() => start(t.slug, 'practice')}>
                    <GraduationCap size={14} /> Practice
                  </Button>
                  <Button size="sm" variant="outline" className="flex-1" onClick={() => start(t.slug, 'drill')}>
                    <Timer size={14} /> Drill
                  </Button>
                </div>
              </Card>
            </motion.div>
          );
        })}
        {topics.length === 0 && (
          <Card className="p-8 md:col-span-3 text-center text-sm text-ink-3">
            No questions in this section yet — they arrive with the book extraction.
            <div className="mt-3">
              <Button size="sm" variant="soft" onClick={() => navigate('/mocks')}>
                <Play size={14} /> Try a mock instead
              </Button>
            </div>
          </Card>
        )}
      </div>
    </div>
  );
}
