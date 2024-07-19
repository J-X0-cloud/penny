import clsx from "clsx";
import { BillRow } from "@/components/phone/Rows";
import { Icon } from "@/components/ui/Icon";
import { BILLS } from "@/lib/data/household";
import { billsTotal } from "@/lib/finance";
import { money } from "@/lib/money";

/** First week of October; dots mark days with a bill due. */
const WEEK = [
  { weekday: "W", day: 1, due: true },
  { weekday: "T", day: 2, due: false },
  { weekday: "F", day: 3, due: true },
  { weekday: "S", day: 4, due: false },
  { weekday: "S", day: 5, due: true },
  { weekday: "M", day: 6, due: false },
  { weekday: "T", day: 7, due: false },
];

export function BillsScreen() {
  const streaming = BILLS.find((bill) => bill.priceChange);
  return (
    <div className="ps-pad">
      <div className="ps-top">
        <div>
          <small>Next 30 days · {BILLS.length} bills</small>
          <h4>Recurring</h4>
        </div>
        <span className="ps-pill">
          <Icon name="plus" />
        </span>
      </div>
      <p className="ps-big dark">{money(billsTotal)}</p>
      <div className="ps-week">
        <p>October</p>
        <div>
          {WEEK.map((d) => (
            <span key={d.day} className={clsx(d.day === 1 && "on")}>
              <small>{d.weekday}</small>
              <b>{d.day}</b>
              {d.due && <i />}
            </span>
          ))}
        </div>
      </div>
      {streaming && (
        <div className="ps-alert">
          <Icon name="bell" />
          <p>
            <b>
              {streaming.name} went up {money(streaming.priceChange ?? 0)}
            </b>
            <small>
              Now {money(streaming.amount)} a month, starting {streaming.due}.
            </small>
          </p>
        </div>
      )}
      <div className="ps-sec tight">
        {BILLS.slice(0, 6).map((bill) => (
          <BillRow key={bill.id} bill={bill} />
        ))}
      </div>
    </div>
  );
}
