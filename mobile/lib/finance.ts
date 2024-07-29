import { accounts, bills, categories, netWorthHistory, period, sharedSpend } from "./data";
import type { AccountGroup, Category, CategoryKey } from "./types";

const round2 = (n: number) => Math.round(n * 100) / 100;

export const categoryByKey = Object.fromEntries(categories.map((c) => [c.key, c])) as Record<CategoryKey, Category>;

export const spent = round2(categories.reduce((sum, c) => sum + c.spent, 0));
export const budget = categories.reduce((sum, c) => sum + c.budget, 0);
export const left = round2(budget - spent);
export const underPace = Math.round((budget * period.day) / period.days - spent);

export const billsTotal = round2(bills.reduce((sum, b) => sum + b.amount, 0));

export const netWorth = round2(accounts.reduce((sum, a) => sum + a.balance, 0));
const quarterAgo = netWorthHistory[netWorthHistory.length - 4] ?? netWorth;
export const netWorthQuarter = { change: Math.round(netWorth - quarterAgo), pct: ((netWorth - quarterAgo) / quarterAgo) * 100 };

export function groupTotals(): { group: AccountGroup; total: number; count: number }[] {
  const order: AccountGroup[] = ["Cash", "Investments", "Other assets", "Liabilities"];
  return order.map((group) => {
    const inGroup = accounts.filter((a) => a.group === group);
    return { group, count: inGroup.length, total: round2(inGroup.reduce((sum, a) => sum + a.balance, 0)) };
  });
}

export function budgetStatus(category: Category) {
  const available = category.budget + category.rollover;
  return {
    available,
    fraction: Math.min(category.spent / available, 1),
    over: category.spent > available,
    remaining: available - category.spent,
  };
}

export const sharedTotal = round2(sharedSpend.M + sharedSpend.J);
export const mayaShare = sharedSpend.M / sharedTotal;
/** Even split: the member who paid less owes half the difference. */
export const jordanOwes = round2((sharedSpend.M - sharedSpend.J) / 2);
