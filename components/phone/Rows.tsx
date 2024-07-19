import { CategoryChip, IconChip } from "@/components/ui/Chip";
import { CATEGORY_BY_KEY } from "@/lib/finance";
import { money } from "@/lib/money";
import type { Bill, Transaction } from "@/types";

export function TransactionRow({ txn, showDate }: { txn: Transaction; showDate?: boolean }) {
  return (
    <div className="ps-row">
      <CategoryChip category={txn.category} />
      <div className="grow">
        <b>{txn.merchant}</b>
        <small>
          {CATEGORY_BY_KEY[txn.category].label} · {showDate ? txn.date : txn.account}
        </small>
      </div>
      <span className="amt">{money(txn.amount)}</span>
    </div>
  );
}

export function PriceChangeFlag({ bill }: { bill: Bill }) {
  if (!bill.priceChange) return null;
  return (
    <>
      {" "}
      <em className="up">+{money(bill.priceChange)}</em>
    </>
  );
}

export function BillRow({ bill }: { bill: Bill }) {
  return (
    <div className="ps-row">
      <IconChip icon={bill.icon} />
      <div className="grow">
        <b>
          {bill.name}
          <PriceChangeFlag bill={bill} />
        </b>
        <small>
          {bill.due}
          {bill.priceChange ? "" : ` · ${bill.note}`}
        </small>
      </div>
      <span className="amt">{money(bill.amount)}</span>
    </div>
  );
}
