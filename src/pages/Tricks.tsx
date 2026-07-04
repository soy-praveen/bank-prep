import { motion } from 'framer-motion';
import { Lightbulb } from 'lucide-react';
import { useMemo, useState } from 'react';
import { Card, Chip, Modal, SectionTitle } from '../components/ui';
import { SECTION_META, topicName, tricks } from '../lib/data';
import { Md } from '../lib/md';
import type { SectionId, Trick } from '../types';

type Filter = SectionId | 'all';

export default function Tricks() {
  const [filter, setFilter] = useState<Filter>('all');
  const [open, setOpen] = useState<Trick | null>(null);

  const list = useMemo(() => (filter === 'all' ? tricks : tricks.filter((t) => t.section === filter)), [filter]);
  const filters: { id: Filter; label: string }[] = [
    { id: 'all', label: 'All' },
    ...(Object.keys(SECTION_META) as SectionId[]).map((s) => ({ id: s as Filter, label: SECTION_META[s].short })),
  ];

  return (
    <div className="space-y-6">
      <SectionTitle
        title="Speed Tricks & Techniques"
        sub="Short methods that convert to real seconds saved in the exam hall"
        right={
          <div className="flex gap-1.5 flex-wrap">
            {filters.map((f) => (
              <button
                key={f.id}
                onClick={() => setFilter(f.id)}
                className={`px-3.5 py-1.5 rounded-lg text-xs font-semibold transition-colors cursor-pointer ${
                  filter === f.id ? 'bg-accent text-white' : 'bg-sunken text-ink-2 hover:text-ink'
                }`}
              >
                {f.label}
              </button>
            ))}
          </div>
        }
      />

      <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-4">
        {list.map((t, i) => (
          <motion.div key={t.id} initial={{ opacity: 0, y: 12 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: Math.min(i * 0.04, 0.3) }}>
            <Card hover className="p-5 h-full flex flex-col gap-2.5" onClick={() => setOpen(t)}>
              <div className="flex items-center justify-between">
                <div className="w-9 h-9 rounded-xl bg-warn-soft text-warn flex items-center justify-center">
                  <Lightbulb size={16} />
                </div>
                <Chip>{SECTION_META[t.section].short}</Chip>
              </div>
              <div className="font-semibold text-[15px] leading-snug">{t.title}</div>
              <p className="text-xs text-ink-3 leading-relaxed">{t.summary}</p>
              <div className="mt-auto pt-1 text-[11px] font-semibold text-accent">{topicName(t.section, t.topic)}</div>
            </Card>
          </motion.div>
        ))}
        {list.length === 0 && (
          <Card className="p-8 md:col-span-3 text-center text-sm text-ink-3">Tricks for this section are on the way.</Card>
        )}
      </div>

      <Modal open={!!open} onClose={() => setOpen(null)} title={open?.title ?? ''} wide>
        {open && (
          <div>
            <div className="flex gap-2 mb-4">
              <Chip tone="accent">{SECTION_META[open.section].short}</Chip>
              <Chip>{topicName(open.section, open.topic)}</Chip>
            </div>
            <Md text={open.body} className="text-sm leading-relaxed text-ink-2" />
          </div>
        )}
      </Modal>
    </div>
  );
}
