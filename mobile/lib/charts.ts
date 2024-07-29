export type Pt = [number, number];

interface ScaleOptions {
  slots?: number;
  min?: number;
  pad?: number;
}

export function toPoints(values: number[], w: number, h: number, max: number, { slots = values.length, min = 0, pad = 4 }: ScaleOptions = {}): Pt[] {
  const step = w / (slots - 1);
  return values.map((v, i) => [i * step, pad + (h - pad * 2) * (1 - (v - min) / (max - min))]);
}

/** Horizontal-tangent cubic smoothing, same curve as the web charts. */
export function smoothPath(points: Pt[]): string {
  const [first, ...rest] = points;
  if (!first) return "";
  let d = `M${first[0]},${first[1]}`;
  let prev = first;
  for (const p of rest) {
    const cx = (prev[0] + p[0]) / 2;
    d += ` C${cx},${prev[1]} ${cx},${p[1]} ${p[0]},${p[1]}`;
    prev = p;
  }
  return d;
}

export function areaPath(points: Pt[], h: number, closeAtX?: number): string {
  const last = points[points.length - 1];
  if (!last) return "";
  return `${smoothPath(points)} L${closeAtX ?? last[0]},${h} L0,${h} Z`;
}
