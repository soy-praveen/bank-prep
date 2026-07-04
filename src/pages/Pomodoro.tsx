import { Pause, Play, RotateCcw, SkipForward } from 'lucide-react';
import { useEffect, useMemo, useRef, useState } from 'react';
import { ActivityBars } from '../components/charts';
import { Button, Card, Ring, SectionTitle, Stat } from '../components/ui';
import { dateKey, useApp } from '../lib/store';

type Mode = 'focus' | 'short' | 'long';
const DEFAULTS: Record<Mode, number> = { focus: 25, short: 5, long: 15 };
const LABELS: Record<Mode, string> = { focus: 'Focus', short: 'Short Break', long: 'Long Break' };

function chime() {
  try {
    const ctx = new AudioContext();
    const play = (freq: number, at: number) => {
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      osc.frequency.value = freq;
      osc.type = 'sine';
      gain.gain.setValueAtTime(0.001, ctx.currentTime + at);
      gain.gain.exponentialRampToValueAtTime(0.18, ctx.currentTime + at + 0.02);
      gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + at + 0.5);
      osc.connect(gain).connect(ctx.destination);
      osc.start(ctx.currentTime + at);
      osc.stop(ctx.currentTime + at + 0.55);
    };
    play(880, 0);
    play(1174.66, 0.18);
  } catch {
    // audio unavailable; silent completion is fine
  }
}

export default function Pomodoro() {
  const { state, logPomodoro } = useApp();
  const [mode, setMode] = useState<Mode>('focus');
  const [durations, setDurations] = useState(DEFAULTS);
  const [remaining, setRemaining] = useState(DEFAULTS.focus * 60);
  const [running, setRunning] = useState(false);
  const [completedFocus, setCompletedFocus] = useState(0);
  const endAtRef = useRef<number | null>(null);

  const total = durations[mode] * 60;

  useEffect(() => {
    if (!running) return;
    endAtRef.current = Date.now() + remaining * 1000;
    const t = setInterval(() => {
      const left = Math.max(0, Math.round(((endAtRef.current ?? 0) - Date.now()) / 1000));
      setRemaining(left);
      if (left <= 0) {
        clearInterval(t);
        setRunning(false);
        chime();
        if (mode === 'focus') {
          logPomodoro(durations.focus);
          setCompletedFocus((n) => n + 1);
          const nextMode: Mode = (completedFocus + 1) % 4 === 0 ? 'long' : 'short';
          setMode(nextMode);
          setRemaining(durations[nextMode] * 60);
        } else {
          setMode('focus');
          setRemaining(durations.focus * 60);
        }
      }
    }, 300);
    return () => clearInterval(t);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [running]);

  const switchMode = (m: Mode) => {
    setMode(m);
    setRunning(false);
    setRemaining(durations[m] * 60);
  };

  const mm = String(Math.floor(remaining / 60)).padStart(2, '0');
  const ss = String(remaining % 60).padStart(2, '0');

  const week = useMemo(() => {
    const days: { label: string; value: number }[] = [];
    for (let i = 6; i >= 0; i--) {
      const d = new Date();
      d.setDate(d.getDate() - i);
      const key = dateKey(d);
      const log = state.pomodoro.find((p) => p.dateKey === key);
      days.push({ label: d.toLocaleDateString(undefined, { weekday: 'short' }), value: log?.focusMinutes ?? 0 });
    }
    return days;
  }, [state.pomodoro]);

  const todayLog = state.pomodoro.find((p) => p.dateKey === dateKey());
  const totalAll = state.pomodoro.reduce((n, p) => n + p.focusMinutes, 0);

  return (
    <div className="space-y-8 max-w-3xl mx-auto">
      <Card className="p-8 flex flex-col items-center">
        <div className="flex gap-1.5 mb-8">
          {(Object.keys(LABELS) as Mode[]).map((m) => (
            <button
              key={m}
              onClick={() => switchMode(m)}
              className={`px-4 py-2 rounded-xl text-sm font-semibold transition-all cursor-pointer ${
                mode === m ? 'bg-accent text-white shadow-sm' : 'text-ink-2 hover:bg-sunken'
              }`}
            >
              {LABELS[m]}
            </button>
          ))}
        </div>

        <Ring fraction={remaining / total} size={230} stroke={11} tone={mode === 'focus' ? 'accent' : 'teal'}>
          <div className="font-display font-bold text-5xl tabular-nums tracking-tight">
            {mm}:{ss}
          </div>
          <div className="text-xs text-ink-3 mt-1.5 uppercase tracking-[0.14em] font-semibold">{LABELS[mode]}</div>
        </Ring>

        <div className="flex items-center gap-2.5 mt-8">
          <Button size="lg" onClick={() => setRunning((r) => !r)}>
            {running ? <Pause size={17} /> : <Play size={17} />} {running ? 'Pause' : 'Start'}
          </Button>
          <Button variant="outline" onClick={() => { setRunning(false); setRemaining(total); }}>
            <RotateCcw size={15} /> Reset
          </Button>
          <Button variant="ghost" onClick={() => { setRunning(false); setRemaining(0); setTimeout(() => setRunning(true), 0); }} disabled={running}>
            <SkipForward size={15} /> Skip
          </Button>
        </div>

        <div className="flex gap-1.5 mt-6">
          {[0, 1, 2, 3].map((i) => (
            <span key={i} className={`w-2 h-2 rounded-full transition-colors ${i < completedFocus % 4 ? 'bg-accent' : 'bg-sunken border border-line'}`} />
          ))}
          <span className="text-[11px] text-ink-3 ml-2">long break every 4 sessions</span>
        </div>

        {/* duration presets */}
        <div className="flex items-center gap-4 mt-7 pt-6 border-t border-line w-full justify-center text-xs">
          {(Object.keys(LABELS) as Mode[]).map((m) => (
            <label key={m} className="flex items-center gap-2 text-ink-3">
              {LABELS[m]}
              <input
                type="number"
                min={1}
                max={120}
                value={durations[m]}
                onChange={(e) => {
                  const v = Math.max(1, Math.min(120, Number(e.target.value) || 1));
                  setDurations((d) => ({ ...d, [m]: v }));
                  if (m === mode && !running) setRemaining(v * 60);
                }}
                className="w-14 px-2 py-1 rounded-lg bg-sunken border border-line text-ink text-center font-semibold focus:border-accent outline-none"
              />
            </label>
          ))}
        </div>
      </Card>

      <div className="grid grid-cols-2 gap-3">
        <Stat label="Today" value={`${todayLog?.focusMinutes ?? 0} min`} sub={`${todayLog?.sessions ?? 0} sessions`} />
        <Stat label="All Time" value={`${Math.round(totalAll / 60)}h ${totalAll % 60}m`} sub={`${state.pomodoro.length} active days`} />
      </div>

      <Card className="p-5">
        <SectionTitle title="Last 7 Days" sub="Focus minutes per day" />
        <ActivityBars data={week} />
      </Card>
    </div>
  );
}
