import { GoalCard } from "@/components/cards/GoalCard";
import { Phone } from "@/components/phone/Phone";
import { Button } from "@/components/ui/Button";
import { IconList } from "@/components/ui/IconList";
import { Eyebrow } from "@/components/ui/SectionHead";
import { GOALS } from "@/lib/data/household";
import { HOUSEHOLD_TICKS } from "@/lib/data/marketing";

export function HouseholdSection() {
  const featured = GOALS.filter((goal) => goal.id === "home" || goal.id === "baby");
  return (
    <section className="sec" id="household">
      <div className="wrap split-2">
        <div className="copy">
          <Eyebrow>Household</Eyebrow>
          <h2>
            Money is a team sport <em>at home.</em>
          </h2>
          <p>
            Invite a partner or roommate and choose exactly which accounts you share. Penny splits the shared spending,
            keeps a running balance of who owes whom and tracks the goals you&rsquo;re saving for together.
          </p>
          <IconList items={HOUSEHOLD_TICKS} />
          <Button href="/household" variant="line" arrow>
            How the household view works
          </Button>
        </div>
        <div className="hh-vis">
          <Phone screen="household" variant="solo" />
          <div className="goal-stack">
            {featured.map((goal) => (
              <GoalCard key={goal.id} goal={goal} />
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}
