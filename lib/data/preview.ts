export type ScreenKey = "home" | "budgets" | "bills" | "networth" | "household";

export const SCREENS: { key: ScreenKey; tab: string; title: string; description: string; icon: "grid" | "pie" | "repeat" | "trend" | "users" }[] = [
  {
    key: "home",
    tab: "Home",
    icon: "grid",
    title: "Today at a glance",
    description:
      "One calm screen each morning: what you’ve spent against your budget, whether you’re on pace, what’s due next and what Penny needs you to look at.",
  },
  {
    key: "budgets",
    tab: "Budgets",
    icon: "pie",
    title: "Budgets that bend",
    description:
      "Set a number per category, watch the ring fill, and let unspent money roll into next month instead of vanishing. Overspending shows up early, in red, while there’s still time to adjust.",
  },
  {
    key: "bills",
    tab: "Bills",
    icon: "repeat",
    title: "Every bill, before it’s due",
    description:
      "Penny spots recurring charges on its own, lays them out on a calendar and flags the ones that quietly got more expensive.",
  },
  {
    key: "networth",
    tab: "Net worth",
    icon: "trend",
    title: "Your whole balance sheet",
    description:
      "Checking, savings, brokerage, retirement, crypto, the car and the loans against them, rolled into one number with a year of history.",
  },
  {
    key: "household",
    tab: "Household",
    icon: "users",
    title: "Shared, not merged",
    description:
      "Invite a partner, choose which accounts you share, see who paid for what and save toward the goals you’re chasing together.",
  },
];
