import Image from "next/image";
import { money } from "@/lib/money";
import type { Goal } from "@/types";

export function GoalCard({ goal }: { goal: Goal }) {
  return (
    <div className="goal">
      <Image src={goal.image} alt="" width={120} height={120} />
      <div>
        <b>{goal.name}</b>
        <small>{goal.note}</small>
      </div>
      <div className="bar">
        <i style={{ width: `${Math.round((goal.saved / goal.target) * 100)}%` }} />
      </div>
      <p>
        <b>{money(goal.saved, 0)}</b> of {money(goal.target, 0)}
      </p>
    </div>
  );
}
