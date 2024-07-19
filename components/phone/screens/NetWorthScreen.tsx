import clsx from "clsx";
import { NetWorthChart } from "@/components/charts/NetWorthChart";
import { IconChip } from "@/components/ui/Chip";
import { Icon, type IconName } from "@/components/ui/Icon";
import { accountGroups, netWorth, netWorthQuarterChange, netWorthQuarterPct } from "@/lib/finance";
import { money } from "@/lib/money";
import type { AccountGroup } from "@/types";

const GROUP_ICON: Record<AccountGroup, IconName> = {
  Cash: "wallet",
  Investments: "trend",
  "Other assets": "car",
  Liabilities: "card",
};

const RANGES = ["1M", "3M", "1Y", "All"] as const;

export function NetWorthScreen() {
  return (
    <div className="ps-pad">
      <div className="ps-top">
        <div>
          <small>All accounts · updated 12m ago</small>
          <h4>Net worth</h4>
        </div>
        <span className="ps-pill">
          <Icon name="sliders" />
        </span>
      </div>
      <p className="ps-big dark">{money(netWorth, 0)}</p>
      <p className="ps-delta">
        <Icon name="up" /> {money(netWorthQuarterChange, 0)} <span>({netWorthQuarterPct.toFixed(1)}%) past 3 months</span>
      </p>
      <div className="chart-box ps-nw">
        <NetWorthChart width={260} height={96} />
      </div>
      <div className="ps-range">
        {RANGES.map((range) => (
          <span key={range} className={clsx(range === "1Y" && "on")}>
            {range}
          </span>
        ))}
      </div>
      <div className="ps-sec tight">
        {accountGroups().map(({ group, total, count }) => (
          <div key={group} className="ps-row">
            <IconChip icon={GROUP_ICON[group]} />
            <div className="grow">
              <b>{group}</b>
              <small>
                {count} account{count > 1 ? "s" : ""}
              </small>
            </div>
            <span className={clsx("amt", total < 0 && "neg")}>{money(total, 0)}</span>
          </div>
        ))}
      </div>
    </div>
  );
}
