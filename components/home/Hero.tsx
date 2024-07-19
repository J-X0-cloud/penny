import Image from "next/image";
import { Phone } from "@/components/phone/Phone";
import { Button } from "@/components/ui/Button";
import { Eyebrow } from "@/components/ui/SectionHead";
import { Icon } from "@/components/ui/Icon";
import { HERO_FLOATS, TRUST_POINTS } from "@/lib/data/marketing";

export function Hero() {
  return (
    <section className="hero">
      <div className="wrap hero-grid">
        <div className="hero-copy">
          <Eyebrow dot>Personal finance for iPhone &amp; the web</Eyebrow>
          <h1>
            Every dollar, <em>right where it belongs.</em>
          </h1>
          <p className="lede">
            Penny brings your checking, cards, loans and investments into one calm place, then sorts your spending,
            watches your bills and keeps your net worth current. For you, or for the whole household.
          </p>
          <div className="btns">
            <Button href="/pricing" size="lg">
              Start 14-day free trial
            </Button>
            <Button href="/app" variant="line" size="lg" arrow>
              Tour the app
            </Button>
          </div>
          <p className="fine">No card needed to start · Works with most US banks, cards and brokerages</p>
        </div>
        <div className="hero-vis">
          <div className="halo" />
          <Phone screen="budgets" variant="back" />
          <Phone screen="home" variant="front" />
          {HERO_FLOATS.map((float) => (
            <div key={float.title} className={`float ${float.className}`}>
              <Image src={float.image} alt="" width={52} height={52} />
              <div>
                <b>{float.title}</b>
                <small>{float.note}</small>
              </div>
            </div>
          ))}
        </div>
      </div>
      <div className="wrap">
        <div className="trust">
          {TRUST_POINTS.map((point) => (
            <span key={point.label}>
              <Icon name={point.icon} />
              {point.label}
            </span>
          ))}
        </div>
      </div>
    </section>
  );
}
