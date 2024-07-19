import { useId } from "react";
import { areaPath, endDot, smoothPath, toPoints } from "@/lib/charts";
import { PERIOD, SPEND_LAST_MONTH, SPEND_THIS_MONTH } from "@/lib/data/household";
import { totalBudget } from "@/lib/finance";

const MAX = 2400;
const GRID_VALUES = [0, 600, 1200, 1800, 2400];

const THEMES = {
  light: { current: "#5B3FD9", last: "#C9C3D9", pace: "#E4A06E", fill: "#5B3FD9" },
  dark: { current: "#FFFFFF", last: "rgba(255,255,255,.38)", pace: "rgba(255,255,255,.28)", fill: "#FFFFFF" },
} as const;

interface SpendChartProps {
  width: number;
  height: number;
  theme?: keyof typeof THEMES;
  axis?: boolean;
}

/** Cumulative spend this month vs. last month, with the straight budget-pace line. */
export function SpendChart({ width: w, height: h, theme = "light", axis = false }: SpendChartProps) {
  const gradientId = useId();
  const colors = THEMES[theme];
  const last = toPoints(SPEND_LAST_MONTH, w, h, MAX);
  const current = toPoints(SPEND_THIS_MONTH, w, h, MAX, { slots: PERIOD.days });
  const [paceStart, paceEnd] = toPoints([0, totalBudget], w, h, MAX);

  return (
    <>
      <svg className="chart" viewBox={`0 0 ${w} ${h}`} preserveAspectRatio="none" aria-hidden="true">
        <defs>
          <linearGradient id={gradientId} x1="0" y1="0" x2="0" y2="1">
            <stop offset="0" stopColor={colors.fill} stopOpacity=".28" />
            <stop offset="1" stopColor={colors.fill} stopOpacity="0" />
          </linearGradient>
        </defs>
        {axis &&
          GRID_VALUES.map((value) => {
            const y = Math.round((4 + (h - 8) * (1 - value / MAX)) * 10) / 10;
            return <line key={value} x1="0" x2={w} y1={y} y2={y} stroke="#EEEAF3" strokeWidth="1" />;
          })}
        {paceStart && paceEnd && (
          <path
            d={`M${paceStart[0]},${paceStart[1]} L${paceEnd[0]},${paceEnd[1]}`}
            stroke={colors.pace}
            strokeWidth="1.4"
            strokeDasharray="2 4"
            fill="none"
            vectorEffect="non-scaling-stroke"
          />
        )}
        <path d={smoothPath(last)} stroke={colors.last} strokeWidth="1.6" strokeDasharray="4 4" fill="none" vectorEffect="non-scaling-stroke" />
        <path d={areaPath(current, h)} fill={`url(#${gradientId})`} />
        <path d={smoothPath(current)} stroke={colors.current} strokeWidth="2.4" fill="none" strokeLinecap="round" vectorEffect="non-scaling-stroke" />
      </svg>
      <span className="chart-dot" style={endDot(current, w, h)} />
    </>
  );
}
