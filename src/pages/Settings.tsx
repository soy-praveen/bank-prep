import { Download, Moon, Pencil, Plus, Sun, Trash2, Upload, UserRound } from 'lucide-react';
import { useRef, useState } from 'react';
import { Button, Card, Chip, Modal, SectionTitle } from '../components/ui';
import { useApp } from '../lib/store';
import type { ProfileState } from '../types';

const HUES = [214, 262, 340, 12, 160, 42];

function ProfileEditor({
  initial,
  onSave,
  onClose,
  title,
}: {
  initial: { name: string; hue: number };
  onSave: (name: string, hue: number) => void;
  onClose: () => void;
  title: string;
}) {
  const [name, setName] = useState(initial.name);
  const [hue, setHue] = useState(initial.hue);
  return (
    <Modal open onClose={onClose} title={title}>
      <div className="space-y-4">
        <div>
          <label className="text-xs font-semibold text-ink-3 uppercase tracking-wider">Name</label>
          <input
            value={name}
            onChange={(e) => setName(e.target.value)}
            maxLength={24}
            className="mt-1.5 w-full px-3.5 py-2.5 rounded-xl bg-sunken border border-line focus:border-accent outline-none text-sm font-medium"
            placeholder="e.g. Praveen"
          />
        </div>
        <div>
          <label className="text-xs font-semibold text-ink-3 uppercase tracking-wider">Colour</label>
          <div className="flex gap-2.5 mt-2">
            {HUES.map((h) => (
              <button
                key={h}
                onClick={() => setHue(h)}
                className={`w-9 h-9 rounded-full transition-transform cursor-pointer ${hue === h ? 'scale-110 ring-2 ring-offset-2 ring-accent ring-offset-surface' : 'hover:scale-105'}`}
                style={{ background: `linear-gradient(135deg, hsl(${h} 70% 52%), hsl(${(h + 40) % 360} 72% 44%))` }}
                aria-label={`Colour ${h}`}
              />
            ))}
          </div>
        </div>
        <div className="flex justify-end gap-2 pt-2">
          <Button variant="ghost" onClick={onClose}>Cancel</Button>
          <Button onClick={() => name.trim() && (onSave(name.trim(), hue), onClose())}>Save</Button>
        </div>
      </div>
    </Modal>
  );
}

export default function Settings() {
  const { theme, setTheme, profiles, profile, setActiveProfile, addProfile, renameProfile, removeProfile, state, resetProfileData, importState } = useApp();
  const [editing, setEditing] = useState<string | null>(null);
  const [adding, setAdding] = useState(false);
  const [confirmReset, setConfirmReset] = useState(false);
  const fileRef = useRef<HTMLInputElement>(null);

  const exportData = () => {
    const payload = {
      exportedAt: new Date().toISOString(),
      profile: profile.name,
      state,
    };
    const blob = new Blob([JSON.stringify(payload, null, 2)], { type: 'application/json' });
    const a = document.createElement('a');
    a.href = URL.createObjectURL(blob);
    a.download = `bankprep-${profile.name.toLowerCase().replace(/\s+/g, '-')}-${Date.now()}.json`;
    a.click();
    URL.revokeObjectURL(a.href);
  };

  const importData = (file: File) => {
    const reader = new FileReader();
    reader.onload = () => {
      try {
        const parsed = JSON.parse(String(reader.result));
        const s = (parsed.state ?? parsed) as ProfileState;
        if (!Array.isArray(s.results)) throw new Error('not a BankPrep export');
        importState(s);
      } catch {
        alert('That file does not look like a BankPrep export.');
      }
    };
    reader.readAsText(file);
  };

  return (
    <div className="space-y-8 max-w-2xl">
      {/* profiles */}
      <div>
        <SectionTitle
          title="Profiles"
          sub="Separate progress for you and your study partner on this device"
          right={
            <Button size="sm" variant="soft" onClick={() => setAdding(true)}>
              <Plus size={14} /> Add
            </Button>
          }
        />
        <div className="space-y-2.5">
          {profiles.map((p) => (
            <Card key={p.id} className="p-4 flex items-center gap-3.5">
              <div
                className="w-10 h-10 rounded-full flex items-center justify-center text-white font-bold"
                style={{ background: `linear-gradient(135deg, hsl(${p.hue} 70% 52%), hsl(${(p.hue + 40) % 360} 72% 44%))` }}
              >
                {p.name.split(/\s+/).map((w) => w[0]).slice(0, 2).join('').toUpperCase()}
              </div>
              <div className="flex-1 min-w-0">
                <div className="font-semibold text-sm flex items-center gap-2">
                  {p.name}
                  {p.id === profile.id && <Chip tone="accent">active</Chip>}
                </div>
                <div className="text-xs text-ink-3">created {new Date(p.createdAt).toLocaleDateString()}</div>
              </div>
              {p.id !== profile.id && (
                <Button size="sm" variant="outline" onClick={() => setActiveProfile(p.id)}>
                  <UserRound size={13} /> Switch
                </Button>
              )}
              <button onClick={() => setEditing(p.id)} className="text-ink-3 hover:text-ink transition-colors p-1.5 cursor-pointer" aria-label="Edit profile">
                <Pencil size={15} />
              </button>
              {profiles.length > 1 && (
                <button
                  onClick={() => confirm(`Delete profile "${p.name}" and all its progress?`) && removeProfile(p.id)}
                  className="text-ink-3 hover:text-danger transition-colors p-1.5 cursor-pointer"
                  aria-label="Delete profile"
                >
                  <Trash2 size={15} />
                </button>
              )}
            </Card>
          ))}
        </div>
      </div>

      {/* appearance */}
      <div>
        <SectionTitle title="Appearance" />
        <Card className="p-4 flex items-center gap-4">
          <div className="flex-1 text-sm font-medium">Theme</div>
          <div className="flex gap-1.5">
            {(['dark', 'light'] as const).map((t) => (
              <button
                key={t}
                onClick={() => setTheme(t)}
                className={`flex items-center gap-2 px-4 py-2 rounded-xl text-sm font-semibold capitalize transition-colors cursor-pointer ${
                  theme === t ? 'bg-accent text-white' : 'bg-sunken text-ink-2 hover:text-ink'
                }`}
              >
                {t === 'dark' ? <Moon size={14} /> : <Sun size={14} />} {t}
              </button>
            ))}
          </div>
        </Card>
      </div>

      {/* data */}
      <div>
        <SectionTitle title="Data" sub="Progress lives in this browser. Export a backup or move it between devices." />
        <Card className="p-4 space-y-3">
          <div className="flex items-center gap-3">
            <div className="flex-1 text-sm">
              <div className="font-medium">Export progress</div>
              <div className="text-xs text-ink-3">{state.results.length} results · {Object.keys(state.topicStats).length} topics tracked</div>
            </div>
            <Button size="sm" variant="outline" onClick={exportData}>
              <Download size={14} /> Export
            </Button>
          </div>
          <div className="flex items-center gap-3 pt-3 border-t border-line">
            <div className="flex-1 text-sm">
              <div className="font-medium">Import progress</div>
              <div className="text-xs text-ink-3">Replaces this profile's data with the backup</div>
            </div>
            <input ref={fileRef} type="file" accept=".json" className="hidden" onChange={(e) => e.target.files?.[0] && importData(e.target.files[0])} />
            <Button size="sm" variant="outline" onClick={() => fileRef.current?.click()}>
              <Upload size={14} /> Import
            </Button>
          </div>
          <div className="flex items-center gap-3 pt-3 border-t border-line">
            <div className="flex-1 text-sm">
              <div className="font-medium text-danger">Reset this profile</div>
              <div className="text-xs text-ink-3">Deletes results, stats, and pomodoro history</div>
            </div>
            <Button size="sm" variant="danger" onClick={() => setConfirmReset(true)}>
              <Trash2 size={14} /> Reset
            </Button>
          </div>
        </Card>
      </div>

      {/* about */}
      <Card className="p-5 text-sm text-ink-2 leading-relaxed">
        <div className="font-display font-semibold text-ink mb-1.5">About BankPrep</div>
        A personal preparation suite for SBI PO and other bank exams, built around the verified 2025-26 exam pattern.
        Question bank blends original practice questions with previous-year extractions. For personal study use.
      </Card>

      {adding && (
        <ProfileEditor
          title="New profile"
          initial={{ name: '', hue: HUES[(profiles.length + 1) % HUES.length] }}
          onSave={(name, hue) => addProfile(name, hue)}
          onClose={() => setAdding(false)}
        />
      )}
      {editing && (
        <ProfileEditor
          title="Edit profile"
          initial={profiles.find((p) => p.id === editing)!}
          onSave={(name, hue) => renameProfile(editing, name, hue)}
          onClose={() => setEditing(null)}
        />
      )}

      <Modal open={confirmReset} onClose={() => setConfirmReset(false)} title="Reset profile data?">
        <p className="text-sm text-ink-2">This permanently deletes all results, topic stats, bookmarks, and pomodoro history for {profile.name}. Consider exporting first.</p>
        <div className="flex justify-end gap-2 mt-5">
          <Button variant="ghost" onClick={() => setConfirmReset(false)}>Cancel</Button>
          <Button variant="danger" onClick={() => { resetProfileData(); setConfirmReset(false); }}>Reset everything</Button>
        </div>
      </Modal>
    </div>
  );
}
