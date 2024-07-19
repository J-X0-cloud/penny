import { PriceChangeFlag } from "@/components/phone/Rows";
import { IconChip } from "@/components/ui/Chip";
import { BILLS, RECURRING_FOUND } from "@/lib/data/household";
import { money } from "@/lib/money";

const SPOTLIGHT = ["streaming", "gym", "car-insurance", "music"];

export function RecurringCard() {
  const bills = SPOTLIGHT.map((id) => BILLS.find((b) => b.id === id)).filter((b) => b !== undefined);
  return (
    <div className="fcard fc-rec">
      <div className="fc-h">
        <b>Recurring</b>
        <span className="tagc v">{RECURRING_FOUND} found</span>
      </div>
      {bills.map((bill) => (
        <div key={bill.id} className="fc-row">
          <IconChip icon={bill.icon} />
          <div className="grow">
            <b>
              {bill.name}
              <PriceChangeFlag bill={bill} />
            </b>
            <small>{bill.due}</small>
          </div>
          <span className="amt">{money(bill.amount)}</span>
        </div>
      ))}
    </div>
  );
}
