import { motion, AnimatePresence } from 'framer-motion';
import { X } from 'lucide-react';
import { useEffect, useState, type ReactNode } from 'react';

export function Button({
  children,
  onClick,
  variant = 'primary',
  size = 'md',
  disabled,
  className = '',
  type = 'button',
}: {
  children: ReactNode;
  onClick?: () => void;
  variant?: 'primary' | 'ghost' | 'outline' | 'danger' | 'soft';
  size?: 'sm' | 'md' | 'lg';
  disabled?: boolean;
  className?: string;
  type?: 'button' | 'submit';
}) {
  const base =
    'inline-flex items-center justify-center gap-2 font-medium rounded-xl transition-all duration-150 active:scale-[0.97] disabled:opacity-45 disabled:pointer-events-none select-none cursor-pointer';
  const sizes = { sm: 'text-xs px-3 h-8', md: 'text-sm px-4 h-10', lg: 'text-[15px] px-6 h-12' };
  const variants = {
    primary: 'bg-accent text-white shadow-[0_4px_14px_-4px_var(--accent)] hover:brightness-110',
    soft: 'bg-accent-soft text-accent hover:bg-accent/20',
    ghost: 'text-ink-2 hover:bg-sunken hover:text-ink',
    outline: 'border border-line-strong text-ink hover:bg-sunken',
    danger: 'bg-danger-soft text-danger hover:bg-danger/20',
  };
  return (
    <button type={type} onClick={onClick} disabled={disabled} className={`${base} ${sizes[size]} ${variants[variant]} ${className}`}>
      {children}
    </button>
  );
}

export function Chip({ children, tone = 'neutral', className = '' }: { children: ReactNode; tone?: 'neutral' | 'accent' | 'teal' | 'danger' | 'warn' | 'violet'; className?: string }) {
  const tones = {
    neutral: 'bg-sunken text-ink-2 border-line',
    accent: 'bg-accent-soft text-accent border-transparent',
    teal: 'bg-teal-soft text-teal border-transparent',
    danger: 'bg-danger-soft text-danger border-transparent',
    warn: 'bg-warn-soft text-warn border-transparent',
    violet: 'bg-violet-soft text-violet border-transparent',
  };
  return (
    <span className={`inline-flex items-center gap-1.5 text-[11px] font-semibold tracking-wide px-2.5 py-1 rounded-full border ${tones[tone]} ${className}`}>
      {children}
    </span>
  );
}

export function Card({ children, className = '', hover = false, onClick }: { children: ReactNode; className?: string; hover?: boolean; onClick?: () => void }) {
  return (
    <div onClick={onClick} className={`card ${hover ? 'card-hover cursor-pointer' : ''} ${className}`}>
      {children}
    </div>
  );
}

export function SectionTitle({ title, sub, right }: { title: string; sub?: string; right?: ReactNode }) {
  return (
    <div className="flex items-end justify-between gap-4 mb-4">
      <div>
        <h2 className="font-display text-lg font-semibold tracking-tight">{title}</h2>
        {sub && <p className="text-sm text-ink-3 mt-0.5">{sub}</p>}
      </div>
      {right}
    </div>
  );
}

/** Animated numeric counter for score reveals. */
export function CountUp({ value, decimals = 0, className = '' }: { value: number; decimals?: number; className?: string }) {
  const [display, setDisplay] = useState(0);
  useEffect(() => {
    const start = performance.now();
    const dur = 900;
    let raf: number;
    const tick = (t: number) => {
      const p = Math.min(1, (t - start) / dur);
      const eased = 1 - Math.pow(1 - p, 3);
      setDisplay(value * eased);
      if (p < 1) raf = requestAnimationFrame(tick);
    };
    raf = requestAnimationFrame(tick);
    return () => cancelAnimationFrame(raf);
  }, [value]);
  return <span className={className}>{display.toFixed(decimals)}</span>;
}

export function Modal({ open, onClose, title, children, wide = false }: { open: boolean; onClose: () => void; title: string; children: ReactNode; wide?: boolean }) {
  return (
    <AnimatePresence>
      {open && (
        <motion.div
          className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/55 backdrop-blur-sm"
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          exit={{ opacity: 0 }}
          onClick={onClose}
        >
          <motion.div
            className={`card w-full ${wide ? 'max-w-2xl' : 'max-w-md'} p-6 max-h-[85vh] overflow-y-auto`}
            initial={{ scale: 0.94, y: 12, opacity: 0 }}
            animate={{ scale: 1, y: 0, opacity: 1 }}
            exit={{ scale: 0.96, y: 8, opacity: 0 }}
            transition={{ type: 'spring', stiffness: 380, damping: 30 }}
            onClick={(e) => e.stopPropagation()}
          >
            <div className="flex items-center justify-between mb-4">
              <h3 className="font-display font-semibold text-lg">{title}</h3>
              <button onClick={onClose} className="text-ink-3 hover:text-ink transition-colors cursor-pointer" aria-label="Close">
                <X size={18} />
              </button>
            </div>
            {children}
          </motion.div>
        </motion.div>
      )}
    </AnimatePresence>
  );
}

/** Circular progress ring (timers, syllabus coverage). */
export function Ring({
  fraction,
  size = 120,
  stroke = 8,
  tone = 'accent',
  children,
}: {
  fraction: number;
  size?: number;
  stroke?: number;
  tone?: 'accent' | 'teal' | 'danger' | 'warn' | 'violet';
  children?: ReactNode;
}) {
  const r = (size - stroke) / 2;
  const c = 2 * Math.PI * r;
  const f = Math.max(0, Math.min(1, fraction));
  const colors = { accent: 'var(--accent)', teal: 'var(--teal)', danger: 'var(--danger)', warn: 'var(--warn)', violet: 'var(--violet)' };
  return (
    <div className="relative inline-flex items-center justify-center" style={{ width: size, height: size }}>
      <svg width={size} height={size} className="-rotate-90">
        <circle cx={size / 2} cy={size / 2} r={r} fill="none" stroke="var(--border)" strokeWidth={stroke} />
        <circle
          cx={size / 2}
          cy={size / 2}
          r={r}
          fill="none"
          stroke={colors[tone]}
          strokeWidth={stroke}
          strokeLinecap="round"
          strokeDasharray={c}
          strokeDashoffset={c * (1 - f)}
          style={{ transition: 'stroke-dashoffset 600ms cubic-bezier(0.22,1,0.36,1), stroke 300ms ease' }}
        />
      </svg>
      <div className="absolute inset-0 flex flex-col items-center justify-center">{children}</div>
    </div>
  );
}

export function Stat({ label, value, sub, tone }: { label: string; value: ReactNode; sub?: string; tone?: 'accent' | 'teal' | 'danger' | 'warn' }) {
  const toneCls = tone ? { accent: 'text-accent', teal: 'text-teal', danger: 'text-danger', warn: 'text-warn' }[tone] : 'text-ink';
  return (
    <div className="card p-4">
      <div className="text-[11px] font-semibold uppercase tracking-[0.08em] text-ink-3">{label}</div>
      <div className={`font-display text-2xl font-bold mt-1 ${toneCls}`}>{value}</div>
      {sub && <div className="text-xs text-ink-3 mt-0.5">{sub}</div>}
    </div>
  );
}

export function EmptyState({ icon, title, sub, action }: { icon: ReactNode; title: string; sub?: string; action?: ReactNode }) {
  return (
    <div className="card p-10 flex flex-col items-center text-center">
      <div className="w-12 h-12 rounded-2xl bg-accent-soft text-accent flex items-center justify-center mb-3">{icon}</div>
      <div className="font-display font-semibold">{title}</div>
      {sub && <div className="text-sm text-ink-3 mt-1 max-w-sm">{sub}</div>}
      {action && <div className="mt-4">{action}</div>}
    </div>
  );
}

export function Progress({ fraction, tone = 'accent', className = '' }: { fraction: number; tone?: 'accent' | 'teal' | 'danger' | 'warn'; className?: string }) {
  const colors = { accent: 'var(--accent)', teal: 'var(--teal)', danger: 'var(--danger)', warn: 'var(--warn)' };
  return (
    <div className={`h-1.5 rounded-full bg-sunken overflow-hidden ${className}`}>
      <div
        className="h-full rounded-full"
        style={{ width: `${Math.min(100, Math.max(0, fraction * 100))}%`, background: colors[tone], transition: 'width 500ms cubic-bezier(0.22,1,0.36,1)' }}
      />
    </div>
  );
}
