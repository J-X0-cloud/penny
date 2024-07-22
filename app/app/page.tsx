import type { Metadata } from "next";
import { WebSection } from "@/components/home/WebSection";
import { CtaBand } from "@/components/layout/CtaBand";
import { PhonePreview } from "@/components/preview/PhonePreview";
import { Icon } from "@/components/ui/Icon";
import { Eyebrow } from "@/components/ui/SectionHead";
import { PLATFORMS } from "@/lib/data/marketing";

export const metadata: Metadata = {
  title: { absolute: "App preview | Penny for iPhone and the web" },
  description:
    "Tap through Penny's iPhone screens, from the daily home view to budgets, recurring bills, net worth and the shared household, plus the web dashboard.",
};

export default function AppPreviewPage() {
  return (
    <>
      <section className="phero center pv-hero">
        <div className="wrap">
          <Eyebrow>Interactive preview</Eyebrow>
          <h1>
            Take Penny <em>for a spin.</em>
          </h1>
          <p className="lede">
            Tap through the real app screens with a sample household&rsquo;s September. On a phone, swipe the screen
            left and right.
          </p>
        </div>
      </section>

      <PhonePreview />

      <WebSection
        eyebrow="Penny on the web"
        title={
          <>
            The same household, <em>on a bigger screen.</em>
          </>
        }
        body="The web app shares one data model with iPhone, so a category fixed on the couch shows up corrected at your desk a second later."
      >
        <div className="plat-row">
          {PLATFORMS.map((platform) => (
            <div key={platform.title}>
              <Icon name={platform.icon} />
              <b>{platform.title}</b>
              <span>{platform.body}</span>
            </div>
          ))}
        </div>
      </WebSection>

      <CtaBand
        title="Like what you see?"
        body="Connect your own accounts and your first month is sorted before the coffee's cold. Free for 14 days."
      />
    </>
  );
}
