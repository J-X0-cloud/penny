import { Icon } from "@/components/ui/Icon";
import { SETUP_STEPS } from "@/lib/data/household-page";

export function SetupSteps() {
  return (
    <ol className="steps">
      {SETUP_STEPS.map((step, i) => (
        <li key={step.title}>
          <span className="n">{i + 1}</span>
          <Icon name={step.icon} />
          <h3>{step.title}</h3>
          <p>{step.body}</p>
        </li>
      ))}
    </ol>
  );
}
