import clsx from "clsx";
import { CategoryChip } from "@/components/ui/Chip";
import { FUN_HISTORY, PERIOD } from "@/lib/data/household";
import { CATEGORY_BY_KEY } from "@/lib/finance";
import { money } from "@/lib/money";

export function RolloverCard() {
  const fun = CATEGORY_BY_KEY.fun;
  const available = fun.budget + fun.rollover;
  return (
    <div className="fcard fc-roll">
      <div className="fc-h">
        <CategoryChip category="fun" />
        <b>{fun.label}</b>
        <span className="tagc">+{money(fun.rollover)} from Aug</span>
      </div>
      <div className="roll-n">
        <div>
          <small>Spent</small>
          <b>{money(fun.spent)}</b>
        </div>
        <div>
          <small>Budget</small>
          <b>{money(available)}</b>
        </div>
        <div>
          <small>Left</small>
          <b className="g">{money(available - fun.spent)}</b>
        </div>
      </div>
      <div className="minibars">
        {FUN_HISTORY.map((m) => (
          <span key={m.month} className={clsx(m.month === PERIOD.short && "on")}>
            <i style={{ height: `${Math.round((m.spent / fun.budget) * 100)}%` }} />
            <small>{m.month}</small>
          </span>
        ))}
        {/* monthly budget line */}
        <em style={{ bottom: "100%" }} />
      </div>
    </div>
  );
}
