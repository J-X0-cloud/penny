import { CtaBand } from "@/components/layout/CtaBand";
import { Hero } from "@/components/home/Hero";
import { HouseholdSection } from "@/components/home/HouseholdSection";
import { PriceTeaser } from "@/components/home/PriceTeaser";
import { Reviews } from "@/components/home/Reviews";
import { SpendingBento } from "@/components/home/SpendingBento";
import { WealthSection } from "@/components/home/WealthSection";
import { WebSection } from "@/components/home/WebSection";

export default function HomePage() {
  return (
    <>
      <Hero />
      <SpendingBento />
      <WealthSection />
      <HouseholdSection />
      <WebSection
        eyebrow="On the web"
        title={
          <>
            Big-screen budgeting, <em>same numbers.</em>
          </>
        }
        body="Everything on your phone is on the web too, with room for the full transaction table, drag-to-edit budgets and bulk recategorizing on a Sunday afternoon."
      />
      <Reviews />
      <PriceTeaser />
      <CtaBand />
    </>
  );
}
