"use client";

import clsx from "clsx";
import { useState } from "react";
import { IconChip } from "@/components/ui/Chip";
import { SHARED_ACCOUNTS } from "@/lib/data/household";

/** Account list with live share toggles, mirroring Settings → Household in the app. */
export function SharedAccountsCard() {
  const [shared, setShared] = useState<Record<string, boolean>>(() =>
    Object.fromEntries(SHARED_ACCOUNTS.map((account) => [account.id, account.shared])),
  );

  return (
    <div className="fcard">
      <div className="fc-h">
        <b>Accounts in this household</b>
      </div>
      {SHARED_ACCOUNTS.map((account) => {
        const on = shared[account.id] ?? false;
        return (
          <div key={account.id} className="fc-row">
            <IconChip icon={account.icon} />
            <div className="grow">
              <b>{account.name}</b>
              <small>{account.institution}</small>
            </div>
            <button
              type="button"
              role="switch"
              aria-checked={on}
              aria-label={`Share ${account.name}`}
              className={clsx("tog", on && "on")}
              onClick={() => setShared((current) => ({ ...current, [account.id]: !on }))}
            >
              <i />
            </button>
            <span className="who">{on ? "Shared" : `Only ${account.owner === "Both" ? "you" : account.owner}`}</span>
          </div>
        );
      })}
    </div>
  );
}
