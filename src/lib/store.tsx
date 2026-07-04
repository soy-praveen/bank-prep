import { createContext, useCallback, useContext, useEffect, useMemo, useState, type ReactNode } from 'react';
import type { PomodoroLog, Profile, ProfileState, TestResult } from '../types';

const K = {
  profiles: 'bp:profiles',
  active: 'bp:active',
  theme: 'bp:theme',
  state: (pid: string) => `bp:state:${pid}`,
};

function load<T>(key: string, fallback: T): T {
  try {
    const raw = localStorage.getItem(key);
    return raw ? { ...fallback, ...JSON.parse(raw) } : fallback;
  } catch {
    return fallback;
  }
}
function save(key: string, value: unknown) {
  localStorage.setItem(key, JSON.stringify(value));
}

const EMPTY_STATE: ProfileState = { results: [], pomodoro: [], topicStats: {}, bookmarks: [], lastActive: 0 };

function defaultProfiles(): Profile[] {
  return [{ id: 'p1', name: 'Aspirant 1', hue: 214, createdAt: Date.now() }];
}

export function dateKey(d = new Date()): string {
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
}

/** Consecutive study-day streak ending today or yesterday. */
export function computeStreak(state: ProfileState): number {
  const days = new Set<string>();
  for (const r of state.results) days.add(dateKey(new Date(r.finishedAt)));
  for (const p of state.pomodoro) if (p.focusMinutes > 0) days.add(p.dateKey);
  let streak = 0;
  const cur = new Date();
  if (!days.has(dateKey(cur))) cur.setDate(cur.getDate() - 1); // allow "yesterday" grace
  while (days.has(dateKey(cur))) {
    streak++;
    cur.setDate(cur.getDate() - 1);
  }
  return streak;
}

interface AppCtx {
  theme: 'dark' | 'light';
  setTheme: (t: 'dark' | 'light') => void;
  profiles: Profile[];
  profile: Profile;
  setActiveProfile: (id: string) => void;
  addProfile: (name: string, hue: number) => void;
  renameProfile: (id: string, name: string, hue: number) => void;
  removeProfile: (id: string) => void;
  state: ProfileState;
  recordResult: (r: TestResult) => void;
  recordPractice: (topic: string, correct: boolean, timeSec: number) => void;
  logPomodoro: (focusMinutes: number) => void;
  toggleBookmark: (qid: string) => void;
  resetProfileData: () => void;
  importState: (s: ProfileState) => void;
}

const Ctx = createContext<AppCtx | null>(null);

export function AppProvider({ children }: { children: ReactNode }) {
  const [theme, setThemeRaw] = useState<'dark' | 'light'>(() => load(K.theme, 'dark'));
  const [profiles, setProfiles] = useState<Profile[]>(() => {
    const p = load(K.profiles, defaultProfiles());
    return p.length ? p : defaultProfiles();
  });
  const [activeId, setActiveId] = useState<string>(() => load(K.active, 'p1'));
  const profile = profiles.find((p) => p.id === activeId) ?? profiles[0];
  const [state, setState] = useState<ProfileState>(() => load(K.state(profile.id), EMPTY_STATE));

  useEffect(() => {
    document.documentElement.dataset.theme = theme;
    save(K.theme, theme);
  }, [theme]);
  useEffect(() => save(K.profiles, profiles), [profiles]);
  useEffect(() => save(K.active, activeId), [activeId]);

  // switch profile -> load its state
  useEffect(() => {
    setState(load(K.state(profile.id), EMPTY_STATE));
  }, [profile.id]);

  const mutate = useCallback(
    (fn: (s: ProfileState) => ProfileState) => {
      setState((prev) => {
        const next = fn(prev);
        next.lastActive = Date.now();
        save(K.state(profile.id), next);
        return next;
      });
    },
    [profile.id],
  );

  const api = useMemo<AppCtx>(
    () => ({
      theme,
      setTheme: setThemeRaw,
      profiles,
      profile,
      setActiveProfile: setActiveId,
      addProfile: (name, hue) =>
        setProfiles((ps) => [...ps, { id: `p${Date.now().toString(36)}`, name, hue, createdAt: Date.now() }]),
      renameProfile: (id, name, hue) =>
        setProfiles((ps) => ps.map((p) => (p.id === id ? { ...p, name, hue } : p))),
      removeProfile: (id) =>
        setProfiles((ps) => {
          if (ps.length <= 1) return ps;
          localStorage.removeItem(K.state(id));
          const next = ps.filter((p) => p.id !== id);
          if (id === activeId) setActiveId(next[0].id);
          return next;
        }),
      state,
      recordResult: (r) =>
        mutate((s) => {
          // fold per-question outcomes into cumulative topic stats
          const topicStats = { ...s.topicStats };
          for (const a of Object.values(r.answers)) {
            if (a.choice === null) continue;
            const t = topicStats[a.topic] ?? { attempted: 0, correct: 0, timeSec: 0 };
            topicStats[a.topic] = {
              attempted: t.attempted + 1,
              correct: t.correct + (a.correct ? 1 : 0),
              timeSec: t.timeSec + a.timeSec,
            };
          }
          return { ...s, results: [...s.results, r], topicStats };
        }),
      recordPractice: (topic, correct, timeSec) =>
        mutate((s) => {
          const t = s.topicStats[topic] ?? { attempted: 0, correct: 0, timeSec: 0 };
          return {
            ...s,
            topicStats: {
              ...s.topicStats,
              [topic]: { attempted: t.attempted + 1, correct: t.correct + (correct ? 1 : 0), timeSec: t.timeSec + timeSec },
            },
          };
        }),
      logPomodoro: (focusMinutes) =>
        mutate((s) => {
          const key = dateKey();
          const logs = [...s.pomodoro];
          const idx = logs.findIndex((l) => l.dateKey === key);
          if (idx >= 0) logs[idx] = { ...logs[idx], focusMinutes: logs[idx].focusMinutes + focusMinutes, sessions: logs[idx].sessions + 1 };
          else logs.push({ dateKey: key, focusMinutes, sessions: 1 } satisfies PomodoroLog);
          return { ...s, pomodoro: logs };
        }),
      toggleBookmark: (qid) =>
        mutate((s) => ({
          ...s,
          bookmarks: s.bookmarks.includes(qid) ? s.bookmarks.filter((b) => b !== qid) : [...s.bookmarks, qid],
        })),
      resetProfileData: () => mutate(() => ({ ...EMPTY_STATE })),
      importState: (imported) => mutate(() => ({ ...EMPTY_STATE, ...imported })),
    }),
    [theme, profiles, profile, state, mutate, activeId],
  );

  return <Ctx.Provider value={api}>{children}</Ctx.Provider>;
}

export function useApp(): AppCtx {
  const ctx = useContext(Ctx);
  if (!ctx) throw new Error('useApp outside provider');
  return ctx;
}
