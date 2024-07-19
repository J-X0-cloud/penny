import clsx from "clsx";
import { useId } from "react";
import { areaPath, endDot, smoothPath, toPoints } from "@/lib/charts";
import { NET_WORTH_HISTORY } from "@/lib/data/household";

export function NetWorthChart({ width: w, height: h, dark = false }: { width: number; height: number; dark?: boolean }) {
  const gradientId = useId();
  const lo = Math.min(...NET_WORTH_HISTORY) - 4000;
  const hi = Math.max(...NET_WORTH_HISTORY) + 2500;
  const points = toPoints(NET_WORTH_HISTORY, w, h, hi, { min: lo });
  const color = dark ? "#B9A8FF" : "#5B3FD9";

  return (
    <>
      <svg className="chart" viewBox={`0 0 ${w} ${h}`} preserveAspectRatio="none" aria-hidden="true">
        <defs>
          <linearGradient id={gradientId} x1="0" y1="0" x2="0" y2="1">
            <stop offset="0" stopColor={color} stopOpacity=".32" />
            <stop offset="1" stopColor={color} stopOpacity="0" />
          </linearGradient>
        </defs>
        <path d={areaPath(points, h, w)} fill={`url(#${gradientId})`} />
        <path d={smoothPath(points)} stroke={color} strokeWidth="2.4" fill="none" vectorEffect="non-scaling-stroke" />
      </svg>
      <span className={clsx("chart-dot", dark && "dk")} style={endDot(points, w, h)} />
    </>
  );
}
