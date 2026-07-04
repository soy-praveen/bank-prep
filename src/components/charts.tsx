import { useMemo, useState } from 'react';

/** Score trend line with area fill and hover dots. Pure SVG, theme-aware. */
export function TrendChart({
  points,
  height = 160,
  maxY,
  labels,
}: {
  points: number[];
  height?: number;
  maxY?: number;
  labels?: string[];
}) {
  const [hover, setHover] = useState<number | null>(null);
  const W = 560;
  const H = height;
  const pad = { l: 34, r: 12, t: 14, b: 22 };
  const top = maxY ?? Math.max(10, ...points) * 1.15;

  const { path, area, xy } = useMemo(() => {
    if (points.length === 0) return { path: '', area: '', xy: [] as [number, number][] };
    const iw = W - pad.l - pad.r;
    const ih = H - pad.t - pad.b;
    const step = points.length > 1 ? iw / (points.length - 1) : 0;
    const xy: [number, number][] = points.map((v, i) => [
      pad.l + (points.length > 1 ? i * step : iw / 2),
      pad.t + ih - (Math.max(0, v) / top) * ih,
    ]);
    const d = xy.map(([x, y], i) => `${i === 0 ? 'M' : 'L'}${x.toFixed(1)},${y.toFixed(1)}`).join(' ');
    const a = `${d} L${xy[xy.length - 1][0]},${H - pad.b} L${xy[0][0]},${H - pad.b} Z`;
    return { path: d, area: a, xy };
  }, [points, top, H]);

  if (points.length === 0) return null;
  const gridYs = [0.25, 0.5, 0.75, 1];

  return (
    <div className="relative">
      <svg viewBox={`0 0 ${W} ${H}`} className="w-full" onMouseLeave={() => setHover(null)}>
        <defs>
          <linearGradient id="trendFill" x1="0" y1="0" x2="0" y2="1">
            <stop offset="0%" stopColor="var(--accent)" stopOpacity="0.28" />
            <stop offset="100%" stopColor="var(--accent)" stopOpacity="0" />
          </linearGradient>
        </defs>
        {gridYs.map((g) => {
          const y = pad.t + (H - pad.t - pad.b) * (1 - g);
          return (
            <g key={g}>
              <line x1={pad.l} x2={W - pad.r} y1={y} y2={y} stroke="var(--border)" strokeDasharray="3 5" />
              <text x={4} y={y + 4} fontSize="10" fill="var(--ink-3)">
                {Math.round(top * g)}
              </text>
            </g>
          );
        })}
        <path d={area} fill="url(#trendFill)" />
        <path d={path} fill="none" stroke="var(--accent)" strokeWidth="2.5" strokeLinejoin="round" strokeLinecap="round" />
        {xy.map(([x, y], i) => (
          <g key={i}>
            <circle
              cx={x}
              cy={y}
              r={hover === i ? 5.5 : 3.5}
              fill="var(--surface)"
              stroke="var(--accent)"
              strokeWidth="2.5"
              style={{ transition: 'r 150ms ease' }}
            />
            <rect
              x={x - 14}
              y={pad.t}
              width={28}
              height={H - pad.t - pad.b}
              fill="transparent"
              onMouseEnter={() => setHover(i)}
            />
          </g>
        ))}
      </svg>
      {hover !== null && (
        <div
          className="absolute pop-in pointer-events-none card px-2.5 py-1.5 text-xs font-semibold"
          style={{ left: `${(xy[hover][0] / W) * 100}%`, top: 0, transform: 'translateX(-50%)' }}
        >
          {points[hover].toFixed(1)}
          {labels?.[hover] && <span className="text-ink-3 font-normal ml-1.5">{labels[hover]}</span>}
        </div>
      )}
    </div>
  );
}

/** Horizontal accuracy bars per topic. */
export function TopicBars({ rows }: { rows: { name: string; fraction: number; detail: string }[] }) {
  return (
    <div className="space-y-3">
      {rows.map((r) => {
        const tone = r.fraction >= 0.75 ? 'var(--teal)' : r.fraction >= 0.5 ? 'var(--warn)' : 'var(--danger)';
        return (
          <div key={r.name}>
            <div className="flex justify-between text-xs mb-1">
              <span className="font-medium text-ink-2">{r.name}</span>
              <span className="text-ink-3">{r.detail}</span>
            </div>
            <div className="h-2 rounded-full bg-sunken overflow-hidden">
              <div
                className="h-full rounded-full"
                style={{ width: `${r.fraction * 100}%`, background: tone, transition: 'width 600ms cubic-bezier(0.22,1,0.36,1)' }}
              />
            </div>
          </div>
        );
      })}
    </div>
  );
}

/** Compact per-day activity columns (pomodoro minutes). */
export function ActivityBars({ data, height = 90 }: { data: { label: string; value: number }[]; height?: number }) {
  const max = Math.max(25, ...data.map((d) => d.value));
  return (
    <div className="flex items-end gap-1.5" style={{ height }}>
      {data.map((d, i) => (
        <div key={i} className="flex-1 flex flex-col items-center gap-1 min-w-0" title={`${d.label}: ${d.value} min`}>
          <div
            className="w-full rounded-md bg-accent"
            style={{
              height: `${Math.max(3, (d.value / max) * (height - 22))}px`,
              opacity: d.value ? 0.45 + 0.55 * (d.value / max) : 0.14,
              transition: 'height 500ms cubic-bezier(0.22,1,0.36,1)',
            }}
          />
          <span className="text-[9px] text-ink-3 truncate">{d.label}</span>
        </div>
      ))}
    </div>
  );
}
