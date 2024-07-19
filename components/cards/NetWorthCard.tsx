import clsx from "clsx";
import { NetWorthChart } from "@/components/charts/NetWorthChart";
import { Icon } from "@/components/ui/Icon";
import { NET_WORTH_MONTHS } from "@/lib/data/household";
import { netWorth, netWorthYearChange } from "@/lib/finance";
import { money } from "@/lib/money";

export function NetWorthCard({ dark = false }: { dark?: boolean }) {
  return (
    <div className={clsx("fcard fc-nw", dark && "dk")}>
      <div className="fc-h">
        <b>Net worth</b>
        <span className="rng">
          <span>3M</span>
          <span className="on">1Y</span>
          <span>All</span>
        </span>
      </div>
      <p className="nw-n">{money(netWorth, 0)}</p>
      <p className="nw-d">
        <Icon name="up" /> {money(netWorthYearChange, 0)} over 12 months
      </p>
      <div className="chart-box nw-chart">
        <NetWorthChart width={520} height={150} dark={dark} />
      </div>
      <div className="ps-axis">
        {NET_WORTH_MONTHS.filter((_, i) => i % 2 === 0).map((month) => (
          <span key={month}>{month}</span>
        ))}
      </div>
    </div>
  );
}
