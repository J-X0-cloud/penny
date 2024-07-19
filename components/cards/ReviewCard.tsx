import { CategoryChip } from "@/components/ui/Chip";
import { Icon } from "@/components/ui/Icon";
import { TRANSACTIONS } from "@/lib/data/household";
import { CATEGORY_BY_KEY } from "@/lib/finance";
import { money } from "@/lib/money";

export function ReviewCard() {
  const queue = TRANSACTIONS.slice(0, 5);
  return (
    <div className="fcard fc-review">
      <div className="fc-h">
        <b>To review</b>
        <span className="count">{queue.length}</span>
        <a>View all</a>
      </div>
      {queue.map((txn) => (
        <div key={txn.id} className="fc-row">
          <CategoryChip category={txn.category} />
          <div className="grow">
            <b>{txn.merchant}</b>
            <small>{CATEGORY_BY_KEY[txn.category].label}</small>
          </div>
          <span className="amt">{money(txn.amount)}</span>
        </div>
      ))}
      <div className="fc-btn">
        <Icon name="check" /> Mark all as reviewed
      </div>
    </div>
  );
}
