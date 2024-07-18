/** SVG geometry for Penny's hand-drawn charts. Pure functions shared by every chart component. */

export type Pt = [number, number];

const r1 = (n: number) => Math.round(n * 10) / 10;

interface ScaleOptions {
  /** Number of x slots; defaults to values.length. Lets a partial month sit on a full-month axis. */
  slots?: number;
  min?: number;
  padTop?: number;
  padBottom?: number;
}

export function toPoints(values: number[], w: number, h: number, max: number, opts: ScaleOptions = {}): Pt[] {
  const { slots = values.length, min = 0, padTop = 4, padBottom = 4 } = opts;
  const step = w / (slots - 1);
  return values.map((v, i) => [r1(i * step), r1(padTop + (h - padTop - padBottom) * (1 - (v - min) / (max - min)))]);
}

/** Horizontal-tangent cubic smoothing: reads as a calm line without overshooting the data. */
export function smoothPath(points: Pt[]): string {
  const [first, ...rest] = points;
  if (!first) return "";
  let d = `M${first[0]},${first[1]}`;
  let prev = first;
  for (const p of rest) {
    const cx = r1((prev[0] + p[0]) / 2);
    d += ` C${cx},${prev[1]} ${cx},${p[1]} ${p[0]},${p[1]}`;
    prev = p;
  }
  return d;
}

export function areaPath(points: Pt[], h: number, closeAtX?: number): string {
  const last = points[points.length - 1];
  if (!last) return "";
  const x = closeAtX ?? last[0];
  return `${smoothPath(points)} L${x},${h} L0,${h} Z`;
}

/** Position of the end-of-line marker as percentages, for an absolutely-positioned HTML dot. */
export function endDot(points: Pt[], w: number, h: number) {
  const last = points[points.length - 1] ?? [0, 0];
  return { left: `${((last[0] / w) * 100).toFixed(2)}%`, top: `${((last[1] / h) * 100).toFixed(2)}%` };
}

export function donutGeometry(size: number, stroke: number, fraction: number) {
  const r = (size - stroke) / 2;
  const c = 2 * Math.PI * r;
  return { r, c, dash: r1(c * fraction), circumference: r1(c), center: size / 2 };
}

export function sparkPath(values: number[], w = 80, h = 26): string {
  const lo = Math.min(...values);
  const hi = Math.max(...values);
  const pad = (hi - lo) * 0.1;
  return smoothPath(toPoints(values, w, h, hi + pad + 0.01, { min: lo - pad }));
}
