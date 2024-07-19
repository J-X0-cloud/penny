import clsx from "clsx";
import { Button } from "@/components/ui/Button";
import { Icon } from "@/components/ui/Icon";
import type { Plan } from "@/types";

export function PlanCard({ plan }: { plan: Plan }) {
  return (
    <div className={clsx("plan", plan.featured && "hi")}>
      {plan.featured && <span className="badge">Most popular</span>}
      <h3>{plan.name}</h3>
      <p className="pd">{plan.description}</p>
      <p className="price">
        {plan.price}
        <span>{plan.period}</span>
      </p>
      <p className="alt">{plan.alt}</p>
      <Button href={plan.ctaHref} variant={plan.featured ? "copper" : "line"} block>
        Start free trial
      </Button>
      <ul>
        {plan.features.map((feature) => (
          <li key={feature}>
            <Icon name="check" />
            {feature}
          </li>
        ))}
      </ul>
    </div>
  );
}
