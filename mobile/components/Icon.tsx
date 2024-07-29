import Svg, { Circle, G, Path, Rect } from "react-native-svg";

/** Same 24×24 line icon set as the web app, drawn with react-native-svg. */
const PATHS = {
  grid: (
    <>
      <Rect x={4} y={4} width={7} height={7} rx={1.8} />
      <Rect x={13} y={4} width={7} height={7} rx={1.8} />
      <Rect x={4} y={13} width={7} height={7} rx={1.8} />
      <Rect x={13} y={13} width={7} height={7} rx={1.8} />
    </>
  ),
  pie: (
    <>
      <Path d="M12 3.5v8.5h8.5A8.5 8.5 0 1 1 12 3.5z" />
      <Path d="M15 3.8A8.6 8.6 0 0 1 20.2 9H15V3.8z" />
    </>
  ),
  repeat: <Path d="M4 11V9a3 3 0 0 1 3-3h12l-3-3M20 13v2a3 3 0 0 1-3 3H5l3 3" />,
  trend: (
    <>
      <Path d="M3 17l6-6 4 4 8-8" />
      <Path d="M15 7h6v6" />
    </>
  ),
  users: (
    <>
      <Circle cx={9} cy={8} r={3.2} />
      <Path d="M3 20a6 6 0 0 1 12 0" />
      <Path d="M16 5.2a3 3 0 0 1 0 5.6M18 14.5a6 6 0 0 1 3 5.5" />
    </>
  ),
  cart: (
    <>
      <Path d="M3 4h2l2.2 10.2a1.5 1.5 0 0 0 1.5 1.2h8.6a1.5 1.5 0 0 0 1.5-1.1L20.5 8H6.2" />
      <Circle cx={9.5} cy={19.5} r={1.3} />
      <Circle cx={17} cy={19.5} r={1.3} />
    </>
  ),
  fork: (
    <>
      <Path d="M7 3v7a2 2 0 0 0 2 2v9M11 3v7a2 2 0 0 1-2 2M9 3v6" />
      <Path d="M17 21V3c-2 1.5-3 4-3 7v3h3" />
    </>
  ),
  home: (
    <>
      <Path d="M4 11l8-7 8 7" />
      <Path d="M6 9.5V20h12V9.5" />
      <Path d="M10 20v-5h4v5" />
    </>
  ),
  car: (
    <>
      <Path d="M4 16v-4l2-5a2 2 0 0 1 1.9-1.4h8.2A2 2 0 0 1 18 7l2 5v4" />
      <Path d="M3 16h18v2.5a1 1 0 0 1-1 1h-2a1 1 0 0 1-1-1V18H7v.5a1 1 0 0 1-1 1H4a1 1 0 0 1-1-1V16z" />
      <Path d="M5 12h14" />
    </>
  ),
  bag: (
    <>
      <Path d="M5 8h14l-1 12H6L5 8z" />
      <Path d="M9 8V6.5a3 3 0 0 1 6 0V8" />
    </>
  ),
  ticket: (
    <>
      <Path d="M4 7h16v3a2 2 0 0 0 0 4v3H4v-3a2 2 0 0 0 0-4V7z" />
      <Path d="M14.5 7.5v9" strokeDasharray="1.5 2.2" />
    </>
  ),
  paw: (
    <>
      <Circle cx={6.5} cy={10.5} r={1.7} />
      <Circle cx={10} cy={6.5} r={1.7} />
      <Circle cx={14.5} cy={6.5} r={1.7} />
      <Circle cx={18} cy={10.5} r={1.7} />
      <Path d="M12 12c-2.5 0-5 3.5-5 5.5 0 1.5 1.2 2.5 2.6 2.1l1.6-.5a3 3 0 0 1 1.6 0l1.6.5c1.4.4 2.6-.6 2.6-2.1 0-2-2.5-5.5-5-5.5z" />
    </>
  ),
  heart: <Path d="M12 20s-7-4.4-7-10a4 4 0 0 1 7-2.6A4 4 0 0 1 19 10c0 5.6-7 10-7 10z" />,
  cup: (
    <>
      <Path d="M5 8h11v5a5 5 0 0 1-5 5h-1a5 5 0 0 1-5-5V8z" />
      <Path d="M16 9.5h1.5a2.5 2.5 0 0 1 0 5H16" />
      <Path d="M8.5 3.5c0 1 1 1.2 1 2.2M12.5 3.5c0 1 1 1.2 1 2.2" />
    </>
  ),
  bolt: <Path d="M13 3L5 13h6l-1 8 8-10h-6l1-8z" />,
  wifi: (
    <>
      <Path d="M3 9a13 13 0 0 1 18 0M6 12.5a8.5 8.5 0 0 1 12 0M9 16a4 4 0 0 1 6 0" />
      <Circle cx={12} cy={19} r={0.6} />
    </>
  ),
  shield: <Path d="M12 3l7 3v5c0 5-3.2 8.3-7 10-3.8-1.7-7-5-7-10V6l7-3z" />,
  phone: (
    <>
      <Rect x={7} y={3} width={10} height={18} rx={2.5} />
      <Path d="M11 18h2" />
    </>
  ),
  play: (
    <>
      <Rect x={3} y={5} width={18} height={13} rx={2.5} />
      <Path d="M10.5 9v5l4-2.5-4-2.5z" />
      <Path d="M8 21h8" />
    </>
  ),
  dumbbell: <Path d="M6.5 7v10M17.5 7v10M3.5 9.5v5M20.5 9.5v5M6.5 12h11" />,
  music: (
    <>
      <Path d="M9 18V6l10-2v12" />
      <Circle cx={6.5} cy={18} r={2.5} />
      <Circle cx={16.5} cy={16} r={2.5} />
    </>
  ),
  wallet: (
    <>
      <Path d="M4 7.5A2.5 2.5 0 0 1 6.5 5H18v3" />
      <Rect x={4} y={8} width={16} height={11} rx={2.5} />
      <Circle cx={16} cy={13.5} r={1.1} />
    </>
  ),
  card: (
    <>
      <Rect x={3} y={6} width={18} height={12} rx={2.5} />
      <Path d="M3 10h18M7 15h3" />
    </>
  ),
  bank: (
    <>
      <Path d="M3 9.5L12 4l9 5.5" />
      <Path d="M5 10v8M9.5 10v8M14.5 10v8M19 10v8M3 20h18" />
    </>
  ),
  bell: (
    <>
      <Path d="M6 16V11a6 6 0 0 1 12 0v5l1.5 2h-15L6 16z" />
      <Path d="M10 20.5a2 2 0 0 0 4 0" />
    </>
  ),
  check: <Path d="M5 12.5l4.5 4.5L19 7.5" />,
  chevd: <Path d="M6 9l6 6 6-6" />,
  plus: <Path d="M12 5v14M5 12h14" />,
  sliders: (
    <>
      <Path d="M4 7h10M18 7h2M4 17h4M12 17h8" />
      <Circle cx={16} cy={7} r={2} />
      <Circle cx={10} cy={17} r={2} />
    </>
  ),
  up: <Path d="M7 14l5-5 5 5" />,
  down: <Path d="M7 10l5 5 5-5" />,
  eyeoff: (
    <>
      <Path d="M4 4l16 16" />
      <Path d="M10 5.7A9.8 9.8 0 0 1 12 5.5c6 0 9.5 6.5 9.5 6.5a17 17 0 0 1-2.6 3.4M6.3 7.4A16 16 0 0 0 2.5 12S6 18.5 12 18.5a9.3 9.3 0 0 0 4-.9" />
    </>
  ),
  split: (
    <>
      <Path d="M6 3.5v4l6 6v7M18 3.5v4l-6 6" />
      <Path d="M4 5.5l2-2 2 2M16 5.5l2-2 2 2" />
    </>
  ),
  target: (
    <>
      <Circle cx={12} cy={12} r={8.5} />
      <Circle cx={12} cy={12} r={4.5} />
      <Circle cx={12} cy={12} r={0.8} />
    </>
  ),
  arrow: <Path d="M5 12h14M13 6l6 6-6 6" />,
} as const;

export type IconName = keyof typeof PATHS;

interface IconProps {
  name: IconName;
  color: string;
  size?: number;
  strokeWidth?: number;
}

export function Icon({ name, color, size = 20, strokeWidth = 1.8 }: IconProps) {
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24">
      <G fill="none" stroke={color} strokeWidth={strokeWidth} strokeLinecap="round" strokeLinejoin="round">
        {PATHS[name]}
      </G>
    </Svg>
  );
}
