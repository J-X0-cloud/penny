import Svg, { Circle, Defs, LinearGradient, Path, Stop } from "react-native-svg";
import { colors } from "@/constants/theme";
import { areaPath, smoothPath, toPoints } from "@/lib/charts";

const W = 300;

export function NetWorthChart({ values, height = 120 }: { values: number[]; height?: number }) {
  const lo = Math.min(...values) - 4000;
  const hi = Math.max(...values) + 2500;
  const points = toPoints(values, W, height, hi, { min: lo });
  const end = points[points.length - 1];

  return (
    <Svg width="100%" height={height} viewBox={`0 0 ${W} ${height}`} preserveAspectRatio="none">
      <Defs>
        <LinearGradient id="nwFill" x1="0" y1="0" x2="0" y2="1">
          <Stop offset="0" stopColor={colors.violet} stopOpacity={0.32} />
          <Stop offset="1" stopColor={colors.violet} stopOpacity={0} />
        </LinearGradient>
      </Defs>
      <Path d={areaPath(points, height, W)} fill="url(#nwFill)" />
      <Path d={smoothPath(points)} stroke={colors.violet} strokeWidth={2.4} fill="none" />
      {end ? <Circle cx={end[0]} cy={end[1]} r={4.5} fill={colors.violet} stroke="#FFFFFF" strokeWidth={2} /> : null}
    </Svg>
  );
}
