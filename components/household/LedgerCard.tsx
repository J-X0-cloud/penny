import { Avatar } from "@/components/ui/Avatar";
import { MEMBERS, SHARED_LEDGER } from "@/lib/data/household";
import { jordanOwes } from "@/lib/finance";
import { money } from "@/lib/money";

export function LedgerCard() {
  return (
    <div className="fcard">
      <div className="fc-h">
        <b>Shared this week</b>
        <span className="tagc v">
          {MEMBERS.J.name} owes {money(jordanOwes)}
        </span>
      </div>
      {SHARED_LEDGER.map((entry) => (
        <div key={entry.id} className="fc-row">
          <Avatar who={entry.paidBy} small />
          <div className="grow">
            <b>{entry.label}</b>
            <small>Paid by {MEMBERS[entry.paidBy].name} · split 50/50</small>
          </div>
          <span className="amt">{money(entry.amount)}</span>
        </div>
      ))}
    </div>
  );
}
