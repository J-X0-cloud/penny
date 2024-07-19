import clsx from "clsx";
import type { ReactNode } from "react";
import { Wordmark } from "@/components/brand/Logo";
import { SpendChart } from "@/components/charts/SpendChart";
import { Sparkline } from "@/components/charts/Sparkline";
import { CoupleAvatars } from "@/components/ui/Avatar";
import { CategoryChip } from "@/components/ui/Chip";
import { Icon, type IconName } from "@/components/ui/Icon";
import {
  BILLS,
  CATEGORIES,
  MONTHLY_INCOME,
  NET_WORTH_HISTORY,
  PERIOD,
  REVIEW_QUEUE_COUNT,
  SPEND_THIS_MONTH,
} from "@/lib/data/household";
import {
  billsTotal,
  budgetStatus,
  leftToBudget,
  netWorth,
  netWorthQuarterChange,
  totalBudget,
  totalSpent,
  underPace,
  vsLastMonthPct,
} from "@/lib/finance";
import { money } from "@/lib/money";
import { TransactionsTable } from "./TransactionsTable";

const SIDEBAR: { icon: IconName; label: string }[] = [
  { icon: "grid", label: "Overview" },
  { icon: "list", label: "Transactions" },
  { icon: "pie", label: "Budgets" },
  { icon: "repeat", label: "Recurring" },
  { icon: "trend", label: "Investments" },
  { icon: "users", label: "Household" },
  { icon: "target", label: "Goals" },
];

interface Kpi {
  label: string;
  value: string;
  delta: ReactNode;
  tone: "good" | "flat";
  trend: number[];
  color: string;
}

const KPIS: Kpi[] = [
  {
    label: "Spent this month",
    value: money(totalSpent),
    delta: (
      <>
        <Icon name="down" /> {Math.abs(vsLastMonthPct).toFixed(1)}% vs Aug
      </>
    ),
    tone: "good",
    trend: SPEND_THIS_MONTH.filter((_, i) => i % 2 === 0),
    color: "#5B3FD9",
  },
  {
    label: "Income",
    value: money(MONTHLY_INCOME),
    delta: "2 paychecks",
    tone: "flat",
    trend: [9850, 9850, 10420, 9850, 9850, 9850],
    color: "#1C9B74",
  },
  {
    label: "Left to budget",
    value: money(leftToBudget),
    delta: `${PERIOD.days - PERIOD.day} days left`,
    tone: "flat",
    trend: [2250, 1900, 1500, 1200, 900, leftToBudget],
    color: "#C8743C",
  },
  {
    label: "Net worth",
    value: money(netWorth, 0),
    delta: (
      <>
        <Icon name="up" /> {money(netWorthQuarterChange, 0)} · 3 mo
      </>
    ),
    tone: "good",
    trend: NET_WORTH_HISTORY,
    color: "#5B3FD9",
  },
];

const Y_LABELS = ["$2.4k", "$1.8k", "$1.2k", "$600", "$0"];
const X_LABELS = [`${PERIOD.short} 1`, "5", "10", "15", "20", "25", "30"];

/** Browser-framed web app overview, built from the same household data as the phone screens. */
export function WebDashboard() {
  return (
    <div
      className="browser"
      role="img"
      aria-label="Penny web dashboard: September overview with spending chart, budgets, transactions and upcoming bills"
    >
      <div className="bbar">
        <i />
        <i />
        <i />
        <span className="url">
          <Icon name="lock" /> app.pennyapp.com/overview
        </span>
      </div>
      <div className="dash">
        <aside className="dside">
          <Wordmark variant="sm" />
          <nav>
            {SIDEBAR.map((item, i) => (
              <span key={item.label} className={clsx(i === 0 && "on")}>
                <Icon name={item.icon} />
                {item.label}
              </span>
            ))}
          </nav>
          <div className="dside-f">
            <small>Viewing</small>
            <span className="vw">
              <CoupleAvatars small />
              Household <Icon name="chevd" />
            </span>
          </div>
        </aside>

        <div className="dmain">
          <div className="dtop">
            <div>
              <small>{PERIOD.todayLong}</small>
              <h3>Overview</h3>
            </div>
            <div className="dctl">
              <span className="seg">
                <span className="on">Month</span>
                <span>Quarter</span>
                <span>Year</span>
              </span>
              <span className="dpill">
                <Icon name="calendar" /> {PERIOD.short} 1 – {PERIOD.short} {PERIOD.days}
              </span>
              <span className="dbtn">
                <Icon name="plus" /> Add account
              </span>
            </div>
          </div>

          <div className="kpis">
            {KPIS.map((kpi) => (
              <div key={kpi.label} className="kpi">
                <small>{kpi.label}</small>
                <b>{kpi.value}</b>
                <div className="kpi-f">
                  <span className={clsx("dlt", kpi.tone)}>{kpi.delta}</span>
                  <Sparkline values={kpi.trend} color={kpi.color} />
                </div>
              </div>
            ))}
          </div>

          <div className="drow">
            <div className="dcard span2">
              <div className="dch">
                <div>
                  <b>Spending this month</b>
                  <small>
                    {money(totalSpent)} spent · {money(underPace, 0)} under budget pace
                  </small>
                </div>
                <span className="lg">
                  <span>
                    <i className="l1" />
                    September
                  </span>
                  <span>
                    <i className="l2" />
                    August
                  </span>
                  <span>
                    <i className="l3" />
                    Budget pace
                  </span>
                </span>
              </div>
              <div className="dchart">
                <div className="yl">
                  {Y_LABELS.map((label) => (
                    <span key={label}>{label}</span>
                  ))}
                </div>
                <div className="chart-box big">
                  <SpendChart width={640} height={210} axis />
                </div>
              </div>
              <div className="xl">
                {X_LABELS.map((label) => (
                  <span key={label}>{label}</span>
                ))}
              </div>
            </div>

            <div className="dcard">
              <div className="dch">
                <div>
                  <b>Budgets</b>
                  <small>
                    {money(leftToBudget, 0)} left of {money(totalBudget, 0)}
                  </small>
                </div>
                <a>Edit</a>
              </div>
              {CATEGORIES.slice(0, 6).map((category) => {
                const status = budgetStatus(category);
                return (
                  <div key={category.key} className="db-row">
                    <CategoryChip category={category.key} size="sm" />
                    <div className="grow">
                      <div className="bl">
                        <b>{category.label}</b>
                        <span className={clsx(status.over && "ov")}>
                          {money(category.spent, 0)} / {money(status.available, 0)}
                        </span>
                      </div>
                      <div className="bar">
                        <i
                          style={{
                            width: `${Math.round(status.fraction * 100)}%`,
                            background: status.over ? "#D4485B" : category.fg,
                          }}
                        />
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>
          </div>

          <div className="drow">
            <div className="dcard span2">
              <div className="dch">
                <div>
                  <b>Recent transactions</b>
                  <small>{REVIEW_QUEUE_COUNT} waiting for review</small>
                </div>
                <span className="dsearch">
                  <Icon name="search" /> Search
                </span>
              </div>
              <TransactionsTable />
            </div>
            <div className="dcard">
              <div className="dch">
                <div>
                  <b>Upcoming</b>
                  <small>{money(billsTotal)} over the next 30 days</small>
                </div>
                <a>Calendar</a>
              </div>
              {BILLS.slice(0, 5).map((bill) => {
                const [month, day] = bill.due.split(" ");
                return (
                  <div key={bill.id} className="db-bill">
                    <span className="dd">
                      <small>{month}</small>
                      <b>{day}</b>
                    </span>
                    <div className="grow">
                      <b>{bill.name}</b>
                      <small>{bill.note}</small>
                    </div>
                    <span className="amt">{money(bill.amount)}</span>
                  </div>
                );
              })}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
