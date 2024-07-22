import type { Metadata } from "next";
import { AllocationCard } from "@/components/cards/AllocationCard";
import { NetWorthCard } from "@/components/cards/NetWorthCard";
import { ReviewCard } from "@/components/cards/ReviewCard";
import { FeatureRow } from "@/components/features/FeatureRow";
import { SecurityGrid } from "@/components/features/SecurityGrid";
import { CtaBand } from "@/components/layout/CtaBand";
import { Phone } from "@/components/phone/Phone";
import { Eyebrow } from "@/components/ui/SectionHead";
import {
  BUDGET_FEATURES,
  FEATURE_ANCHORS,
  NET_WORTH_FEATURES,
  RECURRING_FEATURES,
  TRANSACTION_FEATURES,
} from "@/lib/data/features";

export const metadata: Metadata = {
  title: { absolute: "Features | Penny personal finance app" },
  description:
    "Automatic categories, flexible budgets with rollovers, recurring bill tracking, net worth history and bank-grade security. See everything Penny does.",
};

export default function FeaturesPage() {
  return (
    <>
      <section className="phero">
        <div className="wrap">
          <Eyebrow>Features</Eyebrow>
          <h1>
            The whole toolkit, <em>none of the homework.</em>
          </h1>
          <p className="lede">
            Penny does the sorting, adding and remembering so you can spend five minutes a week deciding instead of an
            evening tallying.
          </p>
          <nav className="subnav" aria-label="Feature sections">
            {FEATURE_ANCHORS.map((anchor) => (
              <a key={anchor.href} href={anchor.href}>
                {anchor.label}
              </a>
            ))}
          </nav>
        </div>
      </section>

      <FeatureRow
        id="transactions"
        eyebrow="Transactions"
        title={
          <>
            Categorized the moment <em>they post.</em>
          </>
        }
        body="Penny reads merchant, amount and timing to file each transaction, then learns from the corrections you make. Rules handle the rest: rename a merchant, split a warehouse-club haul across groceries and home, or hide transfers between your own accounts."
        bullets={TRANSACTION_FEATURES}
      >
        <ReviewCard />
      </FeatureRow>

      <FeatureRow
        id="budgets"
        eyebrow="Budgets"
        flip
        title={
          <>
            Budgets that bend <em>without breaking.</em>
          </>
        }
        body="Give each category a monthly number, or let Penny suggest one from your last three months. Unspent money can roll forward, overspending shows up in red while there's still time, and the pace line tells you whether you're on track mid-month."
        bullets={BUDGET_FEATURES}
      >
        <Phone screen="budgets" variant="solo" />
      </FeatureRow>

      <FeatureRow
        id="recurring"
        eyebrow="Recurring"
        title={
          <>
            Every bill, <em>before it&rsquo;s due.</em>
          </>
        }
        body="Penny finds recurring charges on its own, puts them on a calendar and tells you when one changes. See the next 30 days of bills in a single number and never be surprised by an annual renewal again."
        bullets={RECURRING_FEATURES}
      >
        <Phone screen="bills" variant="solo" />
      </FeatureRow>

      <FeatureRow
        id="networth"
        eyebrow="Net worth"
        flip
        title={
          <>
            Your balance sheet, <em>kept current.</em>
          </>
        }
        body="Link savings, brokerage, retirement and crypto accounts alongside loans and cards. Add manual assets like a car and Penny keeps a monthly history so you can watch the line move the right way."
        bullets={NET_WORTH_FEATURES}
      >
        <div className="fstack">
          <NetWorthCard />
          <AllocationCard />
        </div>
      </FeatureRow>

      <SecurityGrid />
      <CtaBand title="See your month clearly in five minutes." />
    </>
  );
}
