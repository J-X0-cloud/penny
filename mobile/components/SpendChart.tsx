import Svg, { Circle, Defs, LinearGradient, Path, Stop } from "react-native-svg";
import { areaPath, smoothPath, toPoints } from "@/lib/charts";
import { period, spendLastMonth, spendThisMonth } from "@/lib/data";
import { budget } from "@/lib/finance";

const W = 300;
const MAX = 2400;

/** September to date (white) against August (dashed) and the budget pace line, on the hero card. */
export function SpendChart({ height = 80 }: { height?: number }) {
  const current = toPoints(spendThisMonth, W, height, MAX, { slots: period.days });
  const last = toPoints(spendLastMonth, W, height, MAX);
  const [p0, p1] = toPoints([0, budget], W, height, MAX);
  const end = current[current.length - 1];

  return (
    <Svg width="100%" height={height} viewBox={`0 0 ${W} ${height}`} preserveAspectRatio="none">
      <Defs>
        <LinearGradient id="spendFill" x1="0" y1="0" x2="0" y2="1">
          <Stop offset="0" stopColor="#FFFFFF" stopOpacity={0.28} />
          <Stop offset="1" stopColor="#FFFFFF" stopOpacity={0} />
        </LinearGradient>
      </Defs>
      {p0 && p1 ? (
        <Path d={`M${p0[0]},${p0[1]} L${p1[0]},${p1[1]}`} stroke="rgba(255,255,255,0.28)" strokeWidth={1.4} strokeDasharray="2 4" fill="none" />
      ) : null}
      <Path d={smoothPath(last)} stroke="rgba(255,255,255,0.38)" strokeWidth={1.6} strokeDasharray="4 4" fill="none" />
      <Path d={areaPath(current, height)} fill="url(#spendFill)" />
      <Path d={smoothPath(current)} stroke="#FFFFFF" strokeWidth={2.4} strokeLinecap="round" fill="none" />
      {end ? <Circle cx={end[0]} cy={end[1]} r={4.5} fill="#FFFFFF" stroke="#5B3FD9" strokeWidth={2} /> : null}
    </Svg>
  );
}
