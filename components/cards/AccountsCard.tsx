import { IconChip } from "@/components/ui/Chip";
import { ACCOUNTS } from "@/lib/data/household";
import { money } from "@/lib/money";

export function AccountsCard({ limit = 6 }: { limit?: number }) {
  return (
    <div className="fcard fc-acc">
      <div className="fc-h">
        <b>Accounts</b>
        <a>Manage</a>
      </div>
      {ACCOUNTS.slice(0, limit).map((account) => (
        <div key={account.id} className="fc-row">
          <IconChip icon={account.group === "Cash" ? "bank" : "trend"} />
          <div className="grow">
            <b>{account.name}</b>
            <small>
              {account.institution} · {account.updated}
            </small>
          </div>
          <span className="amt">{money(account.balance, 0)}</span>
        </div>
      ))}
    </div>
  );
}
