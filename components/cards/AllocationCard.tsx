import { ALLOCATION } from "@/lib/data/household";

export function AllocationCard() {
  return (
    <div className="fcard fc-alloc">
      <div className="fc-h">
        <b>Allocation</b>
        <small>Investments + cash</small>
      </div>
      <div className="allocbar">
        {ALLOCATION.map((slice) => (
          <i key={slice.label} style={{ width: `${slice.percent}%`, background: slice.color }} />
        ))}
      </div>
      <div className="alloc-l">
        {ALLOCATION.map((slice) => (
          <span key={slice.label}>
            <i style={{ background: slice.color }} />
            {slice.label} <b>{slice.percent}%</b>
          </span>
        ))}
      </div>
    </div>
  );
}
