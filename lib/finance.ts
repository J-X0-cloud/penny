import {
  ACCOUNTS,
  BILLS,
  CASHFLOW,
  CATEGORIES,
  NET_WORTH_HISTORY,
  PERIOD,
  SHARED_SPEND,
  SPEND_LAST_MONTH,
} from "@/lib/data/household";
import type { AccountGroup, Category, CategoryKey } from "@/types";

const round2 = (n: number) => Math.round(n * 100) / 100;

export const CATEGORY_BY_KEY = Object.fromEntries(CATEGORIES.map((c) => [c.key, c])) as Record<CategoryKey, Category>;

export const totalSpent = round2(CATEGORIES.reduce((sum, c) => sum + c.spent, 0));
export const totalBudget = CATEGORIES.reduce((sum, c) => sum + c.budget, 0);
export const leftToBudget = round2(totalBudget - totalSpent);

/** Where spending "should" be today if the budget were spent evenly across the month. */
export const budgetPace = (totalBudget * PERIOD.day) / PERIOD.days;
export const underPace = Math.round(budgetPace - totalSpent);

export const lastMonthAtToday = SPEND_LAST_MONTH[PERIOD.day - 1] ?? 0;
export const vsLastMonthPct = ((totalSpent - lastMonthAtToday) / lastMonthAtToday) * 100;

export const billsTotal = round2(BILLS.reduce((sum, b) => sum + b.amount, 0));

export const netWorth = round2(ACCOUNTS.reduce((sum, a) => sum + a.balance, 0));
export const netWorthYearChange = netWorth - (NET_WORTH_HISTORY[0] ?? netWorth);
const quarterAgo = NET_WORTH_HISTORY[NET_WORTH_HISTORY.length - 4] ?? netWorth;
export const netWorthQuarterChange = Math.round(netWorth - quarterAgo);
export const netWorthQuarterPct = (netWorthQuarterChange / quarterAgo) * 100;

export function accountGroups(): { group: AccountGroup; total: number; count: number }[] {
  const groups: { group: AccountGroup; total: number; count: number }[] = [];
  for (const account of ACCOUNTS) {
    const existing = groups.find((g) => g.group === account.group);
    if (existing) {
      existing.total = round2(existing.total + account.balance);
      existing.count += 1;
    } else {
      groups.push({ group: account.group, total: account.balance, count: 1 });
    }
  }
  return groups;
}

export interface BudgetStatus {
  category: Category;
  available: number;
  fraction: number;
  over: boolean;
  remaining: number;
}

export function budgetStatus(category: Category): BudgetStatus {
  const available = category.budget + category.rollover;
  return {
    category,
    available,
    fraction: Math.min(category.spent / available, 1),
    over: category.spent > available,
    remaining: available - category.spent,
  };
}

export const sharedTotal = round2(SHARED_SPEND.M + SHARED_SPEND.J);
/** Even split: whoever paid less owes half the difference. */
export const jordanOwes = round2((SHARED_SPEND.M - SHARED_SPEND.J) / 2);
export const mayaShare = (SHARED_SPEND.M / sharedTotal) * 100;

export const septemberSaved = (() => {
  const last = CASHFLOW[CASHFLOW.length - 1];
  return last ? { amount: last.income - last.spending, pctOfIncome: ((last.income - last.spending) / last.income) * 100 } : null;
})();
