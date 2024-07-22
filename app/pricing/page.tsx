import type { Metadata } from "next";
import { CtaBand } from "@/components/layout/CtaBand";
import { CompareTable } from "@/components/pricing/CompareTable";
import { PlanCard } from "@/components/pricing/PlanCard";
import { FaqList } from "@/components/ui/FaqList";
import { Icon } from "@/components/ui/Icon";
import { Eyebrow, SectionHead } from "@/components/ui/SectionHead";
import { PLANS, PRICING_FAQ } from "@/lib/data/pricing";
import { CONTACT_EMAIL } from "@/lib/data/site";

export const metadata: Metadata = {
  title: { absolute: "Pricing | Penny personal finance app" },
  description:
    "Penny costs $79 a year for one person or $119 a year for a two-person household, with a 14-day free trial, no ads and no data selling.",
};

export default function PricingPage() {
  return (
    <>
      <section className="phero center">
        <div className="wrap">
          <Eyebrow>Pricing</Eyebrow>
          <h1>
            Honest pricing. <em>No ads, ever.</em>
          </h1>
          <p className="lede">
            Try everything free for 14 days. Then pick the plan that fits how many people are in your money.
          </p>
        </div>
      </section>

      <section className="plans-sec">
        <div className="wrap">
          <div className="plans">
            {PLANS.map((plan) => (
              <PlanCard key={plan.id} plan={plan} />
            ))}
          </div>
          <p className="plans-note">
            <Icon name="lock" /> 14-day free trial on both plans. Cancel any time from Settings.
          </p>
        </div>
      </section>

      <section className="sec">
        <div className="wrap">
          <SectionHead title="Compare plans" />
          <CompareTable />
        </div>
      </section>

      <section className="sec sec-tint" id="faq">
        <div className="wrap faq-wrap">
          <SectionHead
            tone="left"
            eyebrow="FAQ"
            title={
              <>
                Good questions, <em>straight answers.</em>
              </>
            }
          >
            <p>
              Something else? Email <a href={`mailto:${CONTACT_EMAIL}`}>{CONTACT_EMAIL}</a>.
            </p>
          </SectionHead>
          <FaqList items={PRICING_FAQ} />
        </div>
      </section>

      <CtaBand />
    </>
  );
}
