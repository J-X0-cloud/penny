import Image from "next/image";
import { CoupleAvatars } from "@/components/ui/Avatar";
import { GOALS, MEMBERS, PERIOD, SHARED_SPEND } from "@/lib/data/household";
import { jordanOwes, mayaShare, sharedTotal } from "@/lib/finance";
import { money } from "@/lib/money";

export function HouseholdScreen() {
  return (
    <div className="ps-pad">
      <div className="ps-top">
        <div>
          <small>
            {MEMBERS.M.name} &amp; {MEMBERS.J.name}
          </small>
          <h4>Household</h4>
        </div>
        <CoupleAvatars />
      </div>
      <div className="ps-card">
        <small>Shared spending · {PERIOD.month}</small>
        <p className="ps-big dark sm">{money(sharedTotal)}</p>
        <div className="split">
          <i style={{ width: `${Math.round(mayaShare)}%` }} />
          <i style={{ width: `${Math.round(100 - mayaShare)}%` }} />
        </div>
        <div className="split-l">
          <span>
            <i className="dm" />
            {MEMBERS.M.name} {money(SHARED_SPEND.M, 0)}
          </span>
          <span>
            <i className="dj" />
            {MEMBERS.J.name} {money(SHARED_SPEND.J, 0)}
          </span>
        </div>
      </div>
      <div className="ps-settle">
        <div>
          <small>Split 50 / 50</small>
          <b>
            {MEMBERS.J.name} owes you {money(jordanOwes)}
          </b>
        </div>
        <span className="ps-btn">Settle up</span>
      </div>
      <div className="ps-sec tight">
        <h5>
          Shared goals <a>Add</a>
        </h5>
        {GOALS.slice(0, 4).map((goal) => {
          const pct = Math.round((goal.saved / goal.target) * 100);
          return (
            <div key={goal.id} className="ps-goal">
              <Image src={goal.image} alt="" width={40} height={40} />
              <div className="grow">
                <div className="bl">
                  <b>{goal.name}</b>
                  <em>{pct}%</em>
                </div>
                <div className="bar">
                  <i style={{ width: `${pct}%`, background: "#C8743C" }} />
                </div>
                <small>
                  {money(goal.saved, 0)} of {money(goal.target, 0)}
                </small>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}
