import Link from "next/link";
import clsx from "clsx";
import { Eyebrow } from "@/components/ui/SectionHead";
import { PRICE_TEASERS } from "@/lib/data/pricing";

export function PriceTeaser() {
  return (
    <section className="sec sec-price">
      <div className="wrap">
        <div className="price-teaser">
          <div>
            <Eyebrow>Pricing</Eyebrow>
            <h2>
              Honest pricing. <em>You&rsquo;re the customer, not the product.</em>
            </h2>
            <p>
              One plan for you, one for the household. No ads, no upsells and no selling your data, because the
              subscription is the whole business.
            </p>
          </div>
          <div className="pt-cards">
            {PRICE_TEASERS.map((plan) => (
              <Link key={plan.name} className={clsx("pt", "highlight" in plan && plan.highlight && "hi")} href="/pricing">
                <small>{plan.name}</small>
                <b>
                  {plan.monthly}
                  <span>/mo</span>
                </b>
                <p>{plan.note}</p>
              </Link>
            ))}
          </div>
        </div>
      </div>
    </section>
  );
}
