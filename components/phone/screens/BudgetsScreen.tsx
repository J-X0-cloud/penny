import { Donut } from "@/components/charts/Donut";
import { CategoryChip } from "@/components/ui/Chip";
import { Icon } from "@/components/ui/Icon";
import { CATEGORIES, PERIOD } from "@/lib/data/household";
import { budgetStatus, leftToBudget, totalBudget, totalSpent, underPace } from "@/lib/finance";
import { money } from "@/lib/money";

const OVER_COLOR = "#D4485B";

export function BudgetsScreen() {
  return (
    <div className="ps-pad">
      <div className="ps-top">
        <div>
          <small>Monthly budget</small>
          <h4>Budgets</h4>
        </div>
        <span className="ps-pill">
          {PERIOD.short} <Icon name="chevd" />
        </span>
      </div>
      <div className="ps-ring">
        <div className="ring-wrap">
          <Donut fraction={totalSpent / totalBudget} size={92} stroke={10} />
          <div className="ring-c">
            <b>{money(leftToBudget, 0)}</b>
            <small>left</small>
          </div>
        </div>
        <div className="ring-leg">
          <p>
            <i style={{ background: "#5B3FD9" }} />
            Spent <b>{money(totalSpent, 0)}</b>
          </p>
          <p>
            <i style={{ background: "#ECE8F6" }} />
            Budget <b>{money(totalBudget, 0)}</b>
          </p>
          <p className="ok">
            <Icon name="check" /> {money(underPace, 0)} under pace
          </p>
        </div>
      </div>
      <div className="ps-sec tight">
        {CATEGORIES.slice(0, 6).map((category) => {
          const status = budgetStatus(category);
          return (
            <div key={category.key} className="ps-bud">
              <CategoryChip category={category.key} />
              <div className="grow">
                <div className="bl">
                  <b>{category.label}</b>
                  {status.over ? (
                    <em className="ov">{money(category.spent - category.budget, 0)} over</em>
                  ) : category.rollover ? (
                    <em className="ro">+{money(category.rollover, 0)} rollover</em>
                  ) : (
                    <em>{money(status.remaining, 0)} left</em>
                  )}
                </div>
                <div className="bar">
                  <i
                    style={{
                      width: `${Math.round(status.fraction * 100)}%`,
                      background: status.over ? OVER_COLOR : category.fg,
                    }}
                  />
                </div>
                <small>
                  {money(category.spent, 0)} of {money(status.available, 0)}
                </small>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
