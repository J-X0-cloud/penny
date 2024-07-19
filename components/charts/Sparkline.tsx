import { sparkPath } from "@/lib/charts";

export function Sparkline({ values, color = "#5B3FD9" }: { values: number[]; color?: string }) {
  return (
    <svg className="spark" viewBox="0 0 80 26" preserveAspectRatio="none" aria-hidden="true">
      <path d={sparkPath(values)} stroke={color} strokeWidth="1.8" fill="none" vectorEffect="non-scaling-stroke" />
    </svg>
  );
}
