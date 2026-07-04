import { motion } from 'framer-motion';
import { ChevronDown, FileText, PenLine } from 'lucide-react';
import { useMemo, useState } from 'react';
import { Card, Chip, SectionTitle, Stat } from '../components/ui';
import { questionsFor, syllabus } from '../lib/data';
import type { SectionId } from '../types';

const PRIORITY_TONE = { high: 'danger', medium: 'warn', low: 'neutral' } as const;

export default function Syllabus() {
  const [stageId, setStageId] = useState<'prelims' | 'mains'>('prelims');
  const [openSec, setOpenSec] = useState<string | null>(null);

  const stage = syllabus.stages.find((s) => s.id === stageId)!;
  const pattern = stage.pattern as {
    totalQuestions: number;
    totalMarks: number;
    totalMinutes: number;
    sections: { name: string; pool: string; questions: number; marks: number; minutes: number }[];
    descriptive?: { name: string; marks: number; minutes: number; components: string[] };
  };

  const bankCount = useMemo(() => {
    const m = new Map<string, number>();
    for (const sec of stage.syllabus) {
      for (const t of sec.topics) {
        m.set(`${sec.section}:${t.slug}`, questionsFor(sec.section as SectionId, { topic: t.slug, stage: stageId }).length);
      }
    }
    return m;
  }, [stage, stageId]);

  return (
    <div className="space-y-7">
      <div className="flex items-center gap-2">
        {(['prelims', 'mains'] as const).map((st) => (
          <button
            key={st}
            onClick={() => { setStageId(st); setOpenSec(null); }}
            className={`relative px-5 py-2 rounded-xl text-sm font-semibold transition-colors cursor-pointer ${
              stageId === st ? 'text-white' : 'text-ink-2 hover:bg-sunken'
            }`}
          >
            {stageId === st && (
              <motion.div layoutId="syl-pill" className="absolute inset-0 bg-accent rounded-xl" transition={{ type: 'spring', stiffness: 400, damping: 32 }} />
            )}
            <span className="relative z-10">{st === 'prelims' ? 'Prelims' : 'Mains'}</span>
          </button>
        ))}
        <Chip tone="accent" className="ml-2">{syllabus.patternVersion}</Chip>
      </div>

      {/* pattern */}
      <div>
        <SectionTitle title={`${stage.name} — Exam Pattern`} />
        <div className="grid grid-cols-2 md:grid-cols-4 gap-3 mb-4">
          <Stat label="Questions" value={pattern.totalQuestions} />
          <Stat label="Marks" value={pattern.totalMarks} />
          <Stat label="Minutes" value={pattern.totalMinutes} />
          <Stat label="Negative" value="1/4" sub="of question marks" />
        </div>
        <Card className="overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b border-line text-left text-[11px] uppercase tracking-wider text-ink-3">
                  <th className="px-5 py-3 font-bold">Section</th>
                  <th className="px-5 py-3 font-bold text-center">Questions</th>
                  <th className="px-5 py-3 font-bold text-center">Marks</th>
                  <th className="px-5 py-3 font-bold text-center">Minutes</th>
                  <th className="px-5 py-3 font-bold text-center">Marks / Q</th>
                </tr>
              </thead>
              <tbody>
                {pattern.sections.map((s) => (
                  <tr key={s.name} className="border-b border-line last:border-0 hover:bg-raised transition-colors">
                    <td className="px-5 py-3.5 font-medium">{s.name}</td>
                    <td className="px-5 py-3.5 text-center tabular-nums">{s.questions}</td>
                    <td className="px-5 py-3.5 text-center tabular-nums">{s.marks}</td>
                    <td className="px-5 py-3.5 text-center tabular-nums">{s.minutes}</td>
                    <td className="px-5 py-3.5 text-center tabular-nums text-ink-3">{(s.marks / s.questions).toFixed(2)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          {pattern.descriptive && (
            <div className="px-5 py-4 bg-raised border-t border-line flex items-start gap-3">
              <PenLine size={16} className="text-accent mt-0.5 shrink-0" />
              <div className="text-sm">
                <span className="font-semibold">{pattern.descriptive.name}:</span>{' '}
                <span className="text-ink-2">
                  {pattern.descriptive.marks} marks · {pattern.descriptive.minutes} min · {pattern.descriptive.components.join(', ')}
                </span>
              </div>
            </div>
          )}
        </Card>
      </div>

      {/* topic tree */}
      <div>
        <SectionTitle title="Topic-wise Syllabus" sub="Priority reflects weightage in recent papers; counts show questions available in your bank" />
        <div className="space-y-3">
          {stage.syllabus.map((sec) => {
            const open = openSec === sec.name;
            const total = sec.topics.reduce((n, t) => n + (bankCount.get(`${sec.section}:${t.slug}`) ?? 0), 0);
            return (
              <Card key={sec.name} className="overflow-hidden">
                <button
                  onClick={() => setOpenSec(open ? null : sec.name)}
                  className="w-full flex items-center gap-3 px-5 py-4 text-left cursor-pointer hover:bg-raised transition-colors"
                >
                  <FileText size={17} className="text-accent shrink-0" />
                  <span className="font-display font-semibold flex-1">{sec.name}</span>
                  <Chip>{sec.topics.length} topics</Chip>
                  <Chip tone="accent">{total} Q in bank</Chip>
                  <ChevronDown size={16} className={`text-ink-3 transition-transform duration-200 ${open ? 'rotate-180' : ''}`} />
                </button>
                {open && (
                  <motion.div initial={{ opacity: 0 }} animate={{ opacity: 1 }} className="border-t border-line">
                    {sec.topics.map((t) => (
                      <div key={t.slug} className="flex items-start gap-3 px-5 py-3 border-b border-line last:border-0">
                        <div className="flex-1 min-w-0">
                          <div className="text-sm font-medium">{t.name}</div>
                          {t.note && <div className="text-xs text-ink-3 mt-0.5">{t.note}</div>}
                        </div>
                        <Chip tone={PRIORITY_TONE[t.priority as keyof typeof PRIORITY_TONE] ?? 'neutral'}>{t.priority}</Chip>
                        <span className="text-xs text-ink-3 tabular-nums w-10 text-right mt-1">
                          {bankCount.get(`${sec.section}:${t.slug}`) ?? 0} Q
                        </span>
                      </div>
                    ))}
                  </motion.div>
                )}
              </Card>
            );
          })}

          {stageId === 'mains' && 'descriptiveSyllabus' in stage && (
            <Card className="p-5">
              <div className="font-display font-semibold mb-3 flex items-center gap-2">
                <PenLine size={16} className="text-accent" /> Descriptive Paper
              </div>
              <div className="grid sm:grid-cols-2 gap-3">
                {(stage as { descriptiveSyllabus: { slug: string; name: string; note: string }[] }).descriptiveSyllabus.map((d) => (
                  <div key={d.slug} className="p-3 rounded-xl bg-sunken/60">
                    <div className="text-sm font-semibold">{d.name}</div>
                    <div className="text-xs text-ink-3 mt-0.5">{d.note}</div>
                  </div>
                ))}
              </div>
            </Card>
          )}
        </div>
      </div>

      {/* exam notes */}
      <Card className="p-5">
        <div className="font-display font-semibold mb-2">Worth remembering</div>
        <ul className="space-y-1.5 text-sm text-ink-2 list-disc pl-5">
          {syllabus.notes.map((n, i) => (
            <li key={i}>{n}</li>
          ))}
        </ul>
      </Card>
    </div>
  );
}
