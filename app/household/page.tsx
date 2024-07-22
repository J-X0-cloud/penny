import type { Metadata } from "next";
import Image from "next/image";
import { GoalCard } from "@/components/cards/GoalCard";
import { LedgerCard } from "@/components/household/LedgerCard";
import { SetupSteps } from "@/components/household/SetupSteps";
import { SharedAccountsCard } from "@/components/household/SharedAccountsCard";
import { CtaBand } from "@/components/layout/CtaBand";
import { Phone } from "@/components/phone/Phone";
import { Button } from "@/components/ui/Button";
import { FaqList } from "@/components/ui/FaqList";
import { Icon } from "@/components/ui/Icon";
import { Eyebrow, SectionHead } from "@/components/ui/SectionHead";
import { GOALS } from "@/lib/data/household";
import { HOUSEHOLD_FAQ } from "@/lib/data/household-page";

export const metadata: Metadata = {
  title: { absolute: "Household | Shared budgets and goals with Penny" },
  description:
    "Share the accounts you choose with a partner or roommate, split costs fairly, settle up in a tap and save toward shared goals with Penny Household.",
};

export default function HouseholdPage() {
  return (
    <>
      <section className="phero hh-hero">
        <div className="wrap hh-grid">
          <div>
            <Eyebrow>Household</Eyebrow>
            <h1>
              One view for the two of you. <em>Your own accounts, still yours.</em>
            </h1>
            <p className="lede">
              Shared bills, shared goals and a fair split, without merging every account or handing over every receipt.
            </p>
            <div className="btns">
              <Button href="/pricing" size="lg">
                Try Household free
              </Button>
              <Button href="/app" variant="line" size="lg" arrow>
                See the screens
              </Button>
            </div>
          </div>
          <div className="hh-phones">
            <Phone screen="household" variant="front" />
            <div className="float f5">
              <Image src="/images/goal-home.webp" alt="" width={52} height={52} />
              <div>
                <b>Down payment +$400</b>
                <small>Auto-transfer on the 1st</small>
              </div>
            </div>
            <div className="float f6">
              <span className="fi">
                <Icon name="eyeoff" />
              </span>
              <div>
                <b>3 accounts private</b>
                <small>Only you can see them</small>
              </div>
            </div>
          </div>
        </div>
      </section>

      <section className="sec">
        <div className="wrap">
          <SectionHead
            eyebrow="How it works"
            title={
              <>
                Set up in <em>three steps.</em>
              </>
            }
          />
          <SetupSteps />
        </div>
      </section>

      <section className="sec sec-tint">
        <div className="wrap duo">
          <article className="bx">
            <div className="bx-t">
              <h3>Shared and private, side by side</h3>
              <p>Flip an account into the household with one switch. Flip it back any time.</p>
            </div>
            <SharedAccountsCard />
          </article>
          <article className="bx">
            <div className="bx-t">
              <h3>A running tab, settled in a tap</h3>
              <p>Penny tallies who paid for what, applies your split and shows one number to settle.</p>
            </div>
            <LedgerCard />
          </article>
        </div>
      </section>

      <section className="sec" id="goals">
        <div className="wrap">
          <SectionHead
            eyebrow="Shared goals"
            title={
              <>
                Save for the <em>big stuff</em> together.
              </>
            }
          >
            Set a target and a date, and Penny works out the monthly amount, moves it automatically if you like, and
            shows both of you the progress.
          </SectionHead>
          <div className="goals">
            {GOALS.map((goal) => (
              <GoalCard key={goal.id} goal={goal} />
            ))}
          </div>
        </div>
      </section>

      <section className="sec sec-tint">
        <div className="wrap faq-wrap">
          <SectionHead
            tone="left"
            eyebrow="Questions"
            title={
              <>
                Sharing, <em>answered.</em>
              </>
            }
          />
          <FaqList items={HOUSEHOLD_FAQ} />
        </div>
      </section>

      <CtaBand
        title="Run the household like a team."
        body="The Household plan covers two people, two logins and every shared goal. Try it free for 14 days."
      />
    </>
  );
}
