import { NextResponse } from "next/server";
import { PERIOD } from "@/lib/data/household";
import {
  accountGroups,
  billsTotal,
  jordanOwes,
  leftToBudget,
  netWorth,
  netWorthQuarterChange,
  totalBudget,
  totalSpent,
  underPace,
} from "@/lib/finance";

/** Month-at-a-glance numbers for the Home screen and the web Overview. */
export function GET() {
  return NextResponse.json({
    period: { month: PERIOD.month, day: PERIOD.day, days: PERIOD.days },
    spending: { spent: totalSpent, budget: totalBudget, left: leftToBudget, underPace },
    bills: { next30Days: billsTotal },
    netWorth: { total: netWorth, quarterChange: netWorthQuarterChange, groups: accountGroups() },
    household: { owedToMaya: jordanOwes },
  });
}
