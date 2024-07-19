import { donutGeometry } from "@/lib/charts";

interface DonutProps {
  fraction: number;
  size?: number;
  stroke?: number;
  color?: string;
  track?: string;
}

export function Donut({ fraction, size = 96, stroke = 11, color = "#5B3FD9", track = "#ECE8F6" }: DonutProps) {
  const { r, dash, circumference, center } = donutGeometry(size, stroke, fraction);
  return (
    <svg className="donut" viewBox={`0 0 ${size} ${size}`} width={size} height={size} aria-hidden="true">
      <circle cx={center} cy={center} r={r} fill="none" stroke={track} strokeWidth={stroke} />
      <circle
        cx={center}
        cy={center}
        r={r}
        fill="none"
        stroke={color}
        strokeWidth={stroke}
        strokeLinecap="round"
        strokeDasharray={`${dash} ${circumference}`}
        transform={`rotate(-90 ${center} ${center})`}
      />
    </svg>
  );
}
