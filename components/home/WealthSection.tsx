import { AccountsCard } from "@/components/cards/AccountsCard";
import { AllocationCard } from "@/components/cards/AllocationCard";
import { NetWorthCard } from "@/components/cards/NetWorthCard";
import { SectionHead } from "@/components/ui/SectionHead";

export function WealthSection() {
  return (
    <section className="sec sec-dark" id="wealth">
      <div className="wrap">
        <SectionHead
          tone="light"
          eyebrow="Net worth"
          title={
            <>
              Your whole balance sheet, <em>on one screen.</em>
            </>
          }
        >
          Savings, brokerage, retirement, crypto, the car and every loan against it. No more logging into five apps to
          add it all up.
        </SectionHead>
        <div className="wealth">
          <div className="w-main">
            <NetWorthCard dark />
          </div>
          <div className="w-side">
            <AccountsCard limit={4} />
            <AllocationCard />
          </div>
        </div>
      </div>
    </section>
  );
}
