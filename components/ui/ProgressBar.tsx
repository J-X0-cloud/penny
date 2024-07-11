export function ProgressBar({ fraction, color }: { fraction: number; color?: string }) {
  return (
    <div className="bar">
      <i style={{ width: `${Math.round(Math.min(Math.max(fraction, 0), 1) * 100)}%`, background: color }} />
    </div>
  );
}
