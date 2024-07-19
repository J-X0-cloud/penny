import { CASHFLOW, PERIOD } from "@/lib/data/household";
import { septemberSaved } from "@/lib/finance";
import { money } from "@/lib/money";

const SCALE_MAX = 11000;

export function CashflowCard() {
  return (
    <div className="fcard fc-cash">
      <div className="fc-h">
        <b>Cash flow</b>
        <span className="lg">
          <i className="in" />
          Income <i className="ex" />
          Spending
        </span>
      </div>
      {septemberSaved && (
        <p className="cash-n">
          {money(septemberSaved.amount, 0)}{" "}
          <small>
            saved in {PERIOD.month} · {septemberSaved.pctOfIncome.toFixed(0)}% of income
          </small>
        </p>
      )}
      <div className="cashbars">
        {CASHFLOW.map((m) => (
          <span key={m.month}>
            <i className="in" style={{ height: `${Math.round((m.income / SCALE_MAX) * 100)}%` }} />
            <i className="ex" style={{ height: `${Math.round((m.spending / SCALE_MAX) * 100)}%` }} />
            <small>{m.month}</small>
          </span>
        ))}
      </div>
    </div>
  );
}
