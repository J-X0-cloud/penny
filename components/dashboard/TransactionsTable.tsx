import { Avatar } from "@/components/ui/Avatar";
import { CategoryChip } from "@/components/ui/Chip";
import { TRANSACTIONS } from "@/lib/data/household";
import { CATEGORY_BY_KEY } from "@/lib/finance";
import { money } from "@/lib/money";

export function TransactionsTable() {
  return (
    <table className="dtable">
      <thead>
        <tr>
          <th>Date</th>
          <th>Merchant</th>
          <th className="hide-s">Category</th>
          <th className="hide-s hide-m">Account</th>
          <th className="hide-s">By</th>
          <th className="r">Amount</th>
        </tr>
      </thead>
      <tbody>
        {TRANSACTIONS.map((txn) => {
          const category = CATEGORY_BY_KEY[txn.category];
          return (
            <tr key={txn.id}>
              <td className="dt">{txn.date}</td>
              <td>
                <span className="mer">
                  <CategoryChip category={txn.category} size="sm" />
                  {txn.merchant}
                </span>
              </td>
              <td className="hide-s">
                <span className="cat" style={{ color: category.fg, background: category.bg }}>
                  {category.label}
                </span>
              </td>
              <td className="hide-s hide-m">{txn.account}</td>
              <td className="hide-s">
                <Avatar who={txn.paidBy} small />
              </td>
              <td className="r">{money(-txn.amount)}</td>
            </tr>
          );
        })}
      </tbody>
    </table>
  );
}
