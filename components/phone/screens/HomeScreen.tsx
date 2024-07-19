import { SpendChart } from "@/components/charts/SpendChart";
import { BillRow, TransactionRow } from "@/components/phone/Rows";
import { Avatar } from "@/components/ui/Avatar";
import { BILLS, MEMBERS, PERIOD, REVIEW_QUEUE_COUNT, TRANSACTIONS } from "@/lib/data/household";
import { totalBudget, totalSpent, underPace } from "@/lib/finance";
import { money, splitMoney } from "@/lib/money";

export function HomeScreen() {
  const spent = splitMoney(totalSpent);
  return (
    <div className="ps-pad">
      <div className="ps-top">
        <div>
          <small>{PERIOD.todayShort}</small>
          <h4>Good morning, {MEMBERS.M.name}</h4>
        </div>
        <Avatar who="M" />
      </div>
      <div className="ps-hero">
        <div className="ps-hero-h">
          <small>Spent in {PERIOD.month}</small>
          <span className="ps-pill-w">Household</span>
        </div>
        <p className="ps-big">
          {spent.dollars}
          <span>.{spent.cents}</span>
        </p>
        <p className="ps-sub">
          of {money(totalBudget, 0)} budget · <b>{money(underPace, 0)} under pace</b>
        </p>
        <div className="chart-box ps-chart">
          <SpendChart width={260} height={70} theme="dark" />
        </div>
        <div className="ps-axis">
          <span>{PERIOD.short} 1</span>
          <span>15</span>
          <span>{PERIOD.days}</span>
        </div>
      </div>
      <div className="ps-sec">
        <h5>
          Upcoming bills <a>See all</a>
        </h5>
        {BILLS.slice(0, 2).map((bill) => (
          <BillRow key={bill.id} bill={bill} />
        ))}
      </div>
      <div className="ps-sec">
        <h5>
          To review <span className="count">{REVIEW_QUEUE_COUNT}</span>
        </h5>
        {TRANSACTIONS.slice(0, 2).map((txn) => (
          <TransactionRow key={txn.id} txn={txn} showDate />
        ))}
      </div>
    </div>
  );
}
