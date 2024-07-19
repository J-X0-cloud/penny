import { CashflowCard } from "@/components/cards/CashflowCard";
import { RecurringCard } from "@/components/cards/RecurringCard";
import { ReviewCard } from "@/components/cards/ReviewCard";
import { RolloverCard } from "@/components/cards/RolloverCard";
import { RuleCard } from "@/components/cards/RuleCard";
import { SectionHead } from "@/components/ui/SectionHead";

export function SpendingBento() {
  return (
    <section className="sec" id="spending">
      <div className="wrap">
        <SectionHead
          eyebrow="Spending"
          title={
            <>
              Know where it went, <em>without the spreadsheet.</em>
            </>
          }
        >
          Penny tags every transaction the moment it posts and learns from each correction you make. You review, it
          remembers.
        </SectionHead>
        <div className="bento">
          <article className="bx bx-a">
            <div className="bx-t">
              <h3>A review queue, not a chore</h3>
              <p>New transactions land in a short list. Fix a category once and Penny applies it next time.</p>
            </div>
            <RuleCard />
            <ReviewCard />
          </article>
          <article className="bx bx-b">
            <div className="bx-t">
              <h3>Rollovers</h3>
              <p>Didn&rsquo;t use the whole budget? Carry it into next month and save up for something bigger.</p>
            </div>
            <RolloverCard />
          </article>
          <article className="bx bx-c">
            <div className="bx-t">
              <h3>Cash flow</h3>
              <p>Income against spending, month by month, with what you actually kept.</p>
            </div>
            <CashflowCard />
          </article>
          <article className="bx bx-d">
            <div className="bx-t">
              <h3>Subscriptions, spotted</h3>
              <p>The streaming plan that crept up two dollars? Penny noticed.</p>
            </div>
            <RecurringCard />
          </article>
        </div>
      </div>
    </section>
  );
}
