import { AnimatePresence, motion } from 'framer-motion';
import {
  BookOpenText,
  ClipboardList,
  Flame,
  LayoutDashboard,
  Lightbulb,
  ListChecks,
  Menu,
  Moon,
  Landmark,
  Settings,
  Sun,
  Timer,
  X,
  Check,
} from 'lucide-react';
import { useState } from 'react';
import { NavLink, Outlet, useLocation } from 'react-router-dom';
import { computeStreak, useApp } from '../lib/store';

const NAV = [
  { to: '/', label: 'Dashboard', icon: LayoutDashboard, end: true },
  { to: '/mocks', label: 'Mock Tests', icon: ClipboardList },
  { to: '/practice', label: 'Practice', icon: ListChecks },
  { to: '/syllabus', label: 'Syllabus', icon: BookOpenText },
  { to: '/tricks', label: 'Tricks', icon: Lightbulb },
  { to: '/pomodoro', label: 'Focus Timer', icon: Timer },
  { to: '/settings', label: 'Settings', icon: Settings },
];

function Avatar({ name, hue, size = 32 }: { name: string; hue: number; size?: number }) {
  const initials = name
    .split(/\s+/)
    .map((w) => w[0])
    .slice(0, 2)
    .join('')
    .toUpperCase();
  return (
    <div
      className="rounded-full flex items-center justify-center font-bold text-white shrink-0"
      style={{
        width: size,
        height: size,
        fontSize: size * 0.38,
        background: `linear-gradient(135deg, hsl(${hue} 70% 52%), hsl(${(hue + 40) % 360} 72% 44%))`,
      }}
    >
      {initials}
    </div>
  );
}

function NavItems({ onNavigate }: { onNavigate?: () => void }) {
  return (
    <nav className="flex flex-col gap-1 px-3">
      {NAV.map(({ to, label, icon: Icon, end }) => (
        <NavLink key={to} to={to} end={end} onClick={onNavigate}>
          {({ isActive }) => (
            <div
              className={`relative flex items-center gap-3 px-3.5 py-2.5 rounded-xl text-sm font-medium transition-colors duration-150 ${
                isActive ? 'text-accent' : 'text-ink-2 hover:text-ink hover:bg-sunken'
              }`}
            >
              {isActive && (
                <motion.div
                  layoutId="nav-pill"
                  className="absolute inset-0 rounded-xl bg-accent-soft"
                  transition={{ type: 'spring', stiffness: 420, damping: 34 }}
                />
              )}
              <Icon size={17} className="relative z-10" strokeWidth={isActive ? 2.4 : 2} />
              <span className="relative z-10">{label}</span>
            </div>
          )}
        </NavLink>
      ))}
    </nav>
  );
}

function ProfileMenu() {
  const { profiles, profile, setActiveProfile } = useApp();
  const [open, setOpen] = useState(false);
  return (
    <div className="relative">
      <button
        onClick={() => setOpen((o) => !o)}
        className="flex items-center gap-2.5 pl-1.5 pr-3 py-1.5 rounded-full border border-line hover:border-line-strong bg-surface transition-colors cursor-pointer"
      >
        <Avatar name={profile.name} hue={profile.hue} size={26} />
        <span className="text-sm font-semibold max-w-[110px] truncate">{profile.name}</span>
      </button>
      <AnimatePresence>
        {open && (
          <>
            <div className="fixed inset-0 z-30" onClick={() => setOpen(false)} />
            <motion.div
              initial={{ opacity: 0, y: -6, scale: 0.97 }}
              animate={{ opacity: 1, y: 0, scale: 1 }}
              exit={{ opacity: 0, y: -6, scale: 0.97 }}
              transition={{ duration: 0.16 }}
              className="absolute right-0 top-full mt-2 z-40 card p-1.5 w-52 shadow-pop"
            >
              <div className="px-3 py-1.5 text-[10px] font-bold uppercase tracking-[0.1em] text-ink-3">Switch profile</div>
              {profiles.map((p) => (
                <button
                  key={p.id}
                  onClick={() => {
                    setActiveProfile(p.id);
                    setOpen(false);
                  }}
                  className="w-full flex items-center gap-2.5 px-3 py-2 rounded-lg hover:bg-sunken text-sm font-medium transition-colors cursor-pointer"
                >
                  <Avatar name={p.name} hue={p.hue} size={24} />
                  <span className="truncate flex-1 text-left">{p.name}</span>
                  {p.id === profile.id && <Check size={14} className="text-accent" />}
                </button>
              ))}
            </motion.div>
          </>
        )}
      </AnimatePresence>
    </div>
  );
}

export default function Shell() {
  const { theme, setTheme, state } = useApp();
  const location = useLocation();
  const [drawer, setDrawer] = useState(false);
  const streak = computeStreak(state);
  const title = NAV.find((n) => (n.end ? location.pathname === n.to : location.pathname.startsWith(n.to)))?.label ?? 'BankPrep';

  return (
    <div className="min-h-screen flex">
      {/* sidebar (desktop) */}
      <aside className="hidden md:flex w-60 shrink-0 flex-col border-r border-line bg-surface/60 backdrop-blur sticky top-0 h-screen">
        <div className="flex items-center gap-2.5 px-6 h-16">
          <div className="w-8 h-8 rounded-lg bg-accent-soft text-accent flex items-center justify-center">
            <Landmark size={17} strokeWidth={2.2} />
          </div>
          <div className="font-display font-bold tracking-tight text-[17px]">
            Bank<span className="text-accent">Prep</span>
          </div>
        </div>
        <div className="mt-2 flex-1 overflow-y-auto pb-4">
          <NavItems />
        </div>
        <div className="px-6 py-4 border-t border-line text-[11px] text-ink-3 leading-relaxed">
          SBI PO 2025-26 pattern
          <br />
          Personal prep suite
        </div>
      </aside>

      {/* mobile drawer */}
      <AnimatePresence>
        {drawer && (
          <>
            <motion.div
              className="fixed inset-0 z-40 bg-black/50 md:hidden"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              onClick={() => setDrawer(false)}
            />
            <motion.aside
              className="fixed z-50 inset-y-0 left-0 w-64 bg-surface border-r border-line md:hidden flex flex-col"
              initial={{ x: -280 }}
              animate={{ x: 0 }}
              exit={{ x: -280 }}
              transition={{ type: 'spring', stiffness: 380, damping: 36 }}
            >
              <div className="flex items-center justify-between px-5 h-16">
                <div className="font-display font-bold text-[17px]">
                  Bank<span className="text-accent">Prep</span>
                </div>
                <button onClick={() => setDrawer(false)} className="text-ink-3 cursor-pointer" aria-label="Close menu">
                  <X size={20} />
                </button>
              </div>
              <NavItems onNavigate={() => setDrawer(false)} />
            </motion.aside>
          </>
        )}
      </AnimatePresence>

      {/* main column */}
      <div className="flex-1 min-w-0 flex flex-col">
        <header className="sticky top-0 z-30 h-16 flex items-center gap-3 px-4 md:px-8 border-b border-line bg-bg/80 backdrop-blur-md">
          <button className="md:hidden text-ink-2 cursor-pointer" onClick={() => setDrawer(true)} aria-label="Open menu">
            <Menu size={20} />
          </button>
          <h1 className="font-display font-semibold text-[15px] tracking-tight text-ink-2">{title}</h1>
          <div className="ml-auto flex items-center gap-2.5">
            {streak > 0 && (
              <div className="hidden sm:flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-warn-soft text-warn text-xs font-bold">
                <Flame size={13} strokeWidth={2.5} />
                {streak} day{streak > 1 ? 's' : ''}
              </div>
            )}
            <button
              onClick={() => setTheme(theme === 'dark' ? 'light' : 'dark')}
              className="w-9 h-9 rounded-full border border-line hover:border-line-strong flex items-center justify-center text-ink-2 transition-colors cursor-pointer"
              aria-label="Toggle theme"
            >
              <AnimatePresence mode="wait" initial={false}>
                <motion.span
                  key={theme}
                  initial={{ rotate: -90, opacity: 0 }}
                  animate={{ rotate: 0, opacity: 1 }}
                  exit={{ rotate: 90, opacity: 0 }}
                  transition={{ duration: 0.18 }}
                  className="flex"
                >
                  {theme === 'dark' ? <Sun size={16} /> : <Moon size={16} />}
                </motion.span>
              </AnimatePresence>
            </button>
            <ProfileMenu />
          </div>
        </header>

        <main className="flex-1 px-4 md:px-8 py-6 md:py-8 max-w-6xl w-full mx-auto">
          <AnimatePresence mode="wait">
            <motion.div
              key={location.pathname}
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0, y: -6 }}
              transition={{ duration: 0.22, ease: [0.22, 1, 0.36, 1] }}
            >
              <Outlet />
            </motion.div>
          </AnimatePresence>
        </main>
      </div>
    </div>
  );
}
