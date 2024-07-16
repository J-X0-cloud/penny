import type {
  Account,
  AllocationSlice,
  Bill,
  CashflowMonth,
  Category,
  Goal,
  Transaction,
} from "@/types";

/**
 * Sample household: Maya & Jordan, September. Every page, phone screen and the web dashboard read
 * from this module (via lib/finance.ts) so the numbers agree everywhere.
 */

export const MEMBERS = {
  M: { name: "Maya", initial: "M" },
  J: { name: "Jordan", initial: "J" },
} as const;

export const PERIOD = {
  month: "September",
  short: "Sep",
  todayLong: "Wednesday, September 24",
  todayShort: "Wednesday, Sep 24",
  day: 24,
  days: 30,
} as const;

export const CATEGORIES: Category[] = [
  { key: "groceries", label: "Groceries", icon: "cart", fg: "#1C9B74", bg: "#DDF3EA", spent: 548.2, budget: 650, rollover: 0 },
  { key: "dining", label: "Dining out", icon: "fork", fg: "#D4485B", bg: "#FBE3E6", spent: 312.75, budget: 300, rollover: 0 },
  { key: "home", label: "Home", icon: "home", fg: "#5B3FD9", bg: "#EEE9FD", spent: 214.1, budget: 300, rollover: 0 },
  { key: "transport", label: "Transport", icon: "car", fg: "#2F7FD1", bg: "#E1EEFB", spent: 186.4, budget: 260, rollover: 0 },
  { key: "shopping", label: "Shopping", icon: "bag", fg: "#C8743C", bg: "#F7E3D2", spent: 142.37, budget: 250, rollover: 0 },
  { key: "fun", label: "Fun", icon: "ticket", fg: "#B8860B", bg: "#FBF0D2", spent: 96.3, budget: 180, rollover: 42.33 },
  { key: "pets", label: "Pets", icon: "paw", fg: "#8E5BC8", bg: "#F1E7FB", spent: 88, budget: 120, rollover: 0 },
  { key: "health", label: "Health", icon: "heart", fg: "#E0678A", bg: "#FCE6ED", spent: 64, budget: 120, rollover: 0 },
  { key: "coffee", label: "Coffee", icon: "cup", fg: "#7A5A3C", bg: "#F1E8DF", spent: 56.3, budget: 70, rollover: 0 },
];

export const TRANSACTIONS: Transaction[] = [
  { id: "t1", merchant: "Harvest Co-op", category: "groceries", amount: 57.81, date: "Today", account: "Joint checking", paidBy: "M" },
  { id: "t2", merchant: "Nori House", category: "dining", amount: 42.36, date: "Today", account: "Northstar Visa", paidBy: "J" },
  { id: "t3", merchant: "Bluebird Coffee", category: "coffee", amount: 6.75, date: "Today", account: "Maya’s debit", paidBy: "M" },
  { id: "t4", merchant: "Parkline Garage", category: "transport", amount: 18, date: "Sep 23", account: "Northstar Visa", paidBy: "J" },
  { id: "t5", merchant: "Linden Pet Supply", category: "pets", amount: 34.2, date: "Sep 23", account: "Joint checking", paidBy: "M" },
  { id: "t6", merchant: "Marigold Books", category: "shopping", amount: 24.99, date: "Sep 22", account: "Maya’s debit", paidBy: "M" },
  { id: "t7", merchant: "Juniper Pharmacy", category: "health", amount: 18.4, date: "Sep 22", account: "Northstar Visa", paidBy: "J" },
];

export const REVIEW_QUEUE_COUNT = 4;

export const BILLS: Bill[] = [
  { id: "rent", name: "Rent", icon: "home", amount: 2150, due: "Oct 1", note: "Maple Court Apts" },
  { id: "electric", name: "Electric", icon: "bolt", amount: 86.42, due: "Oct 3", note: "Estimated" },
  { id: "internet", name: "Internet", icon: "wifi", amount: 60, due: "Oct 5", note: "Fiber 500" },
  { id: "car-insurance", name: "Car insurance", icon: "shield", amount: 142, due: "Oct 8", note: "Monthly" },
  { id: "phone", name: "Phone plan", icon: "phone", amount: 65, due: "Oct 12", note: "2 lines" },
  { id: "streaming", name: "Streaming", icon: "play", amount: 17.99, due: "Oct 14", note: "Up $2.00", priceChange: 2 },
  { id: "gym", name: "Gym", icon: "dumbbell", amount: 39, due: "Oct 18", note: "Monthly" },
  { id: "music", name: "Music", icon: "music", amount: 11.99, due: "Oct 21", note: "Family plan" },
];

export const RECURRING_FOUND = 11;

export const ACCOUNTS: Account[] = [
  { id: "a1", group: "Cash", name: "Joint checking", institution: "Harbor Credit Union", balance: 8412.55, updated: "2h ago" },
  { id: "a2", group: "Cash", name: "High-yield savings", institution: "Harbor Credit Union", balance: 16448.1, updated: "2h ago" },
  { id: "a3", group: "Investments", name: "Brokerage", institution: "Summit Invest", balance: 41870.22, updated: "1h ago" },
  { id: "a4", group: "Investments", name: "401(k)", institution: "Keystone Retirement", balance: 58215.4, updated: "6h ago" },
  { id: "a5", group: "Investments", name: "Roth IRA", institution: "Summit Invest", balance: 18904.66, updated: "1h ago" },
  { id: "a6", group: "Investments", name: "Crypto", institution: "Cold wallet", balance: 2318.09, updated: "12m ago" },
  { id: "a7", group: "Other assets", name: "2021 hatchback", institution: "Manual estimate", balance: 17500, updated: "Sep 1" },
  { id: "a8", group: "Liabilities", name: "Auto loan", institution: "Harbor Credit Union", balance: -11240.18, updated: "2h ago" },
  { id: "a9", group: "Liabilities", name: "Visa Signature", institution: "Northstar Card", balance: -1842.37, updated: "3h ago" },
  { id: "a10", group: "Liabilities", name: "Student loan", institution: "Federal servicer", balance: -9760, updated: "1d ago" },
];

/** Month-end net worth, October last year through this September. */
export const NET_WORTH_MONTHS = ["Oct", "Nov", "Dec", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep"];
export const NET_WORTH_HISTORY = [122976, 124635, 126658, 129920, 131623, 133470, 132987, 133735, 135595, 137857, 140673, 140826];

/** Cumulative spend by day. This month runs to today; last month is complete. */
export const SPEND_THIS_MONTH = [
  65.02, 136.7, 211.36, 294.28, 365.85, 504.88, 558.89, 615.1, 698.07, 764.55, 845.13, 881.62, 977.51, 1052.23, 1112.82,
  1175.1, 1205.98, 1248.26, 1294.05, 1432.52, 1556.65, 1595.73, 1670.5, 1708.42,
];
export const SPEND_LAST_MONTH = [
  60.21, 115.02, 155.72, 240.19, 272.95, 379.36, 526.2, 563.43, 629.13, 698.57, 733.4, 788.56, 915.49, 1016.72, 1092.68,
  1134.5, 1181.18, 1220.22, 1283.03, 1432.48, 1547.85, 1626.77, 1682.2, 1759.43, 1797.91, 1847.79, 1971.73, 2100.93,
  2158.66, 2196.3,
];

export const CASHFLOW: CashflowMonth[] = [
  { month: "Apr", income: 9850, spending: 6420 },
  { month: "May", income: 9850, spending: 7110 },
  { month: "Jun", income: 10420, spending: 6880 },
  { month: "Jul", income: 9850, spending: 7640 },
  { month: "Aug", income: 9850, spending: 6310 },
  { month: "Sep", income: 9850, spending: 5980 },
];

export const MONTHLY_INCOME = 9850;

/** "Fun" spend per month, used by the rollover card. */
export const FUN_HISTORY = [
  { month: "Apr", spent: 142 },
  { month: "May", spent: 168 },
  { month: "Jun", spent: 121 },
  { month: "Jul", spent: 176 },
  { month: "Aug", spent: 137 },
  { month: "Sep", spent: 96 },
];

export const ALLOCATION: AllocationSlice[] = [
  { label: "US stocks", percent: 49, color: "#5B3FD9" },
  { label: "International", percent: 18, color: "#8C74F0" },
  { label: "Bonds", percent: 13, color: "#C8743C" },
  { label: "Cash", percent: 17, color: "#1C9B74" },
  { label: "Crypto", percent: 3, color: "#E0B04A" },
];

/** Shared spending this month, by who paid. */
export const SHARED_SPEND = { M: 1352.1, J: 1134.1 } as const;

export const GOALS: Goal[] = [
  { id: "home", name: "Down payment", image: "/images/goal-home.webp", saved: 38400, target: 80000, note: "Target: spring 2028" },
  { id: "trip", name: "Yosemite in May", image: "/images/goal-trip.webp", saved: 1150, target: 1800, note: "$130 a month" },
  { id: "baby", name: "Baby fund", image: "/images/goal-baby.webp", saved: 2600, target: 6000, note: "Auto-saves $200" },
  { id: "date", name: "Anniversary dinner", image: "/images/goal-date.webp", saved: 180, target: 250, note: "Nov 14" },
  { id: "party", name: "Sam’s wedding trip", image: "/images/goal-party.webp", saved: 420, target: 900, note: "June" },
];

export const SHARED_ACCOUNTS = [
  { id: "s1", name: "Joint checking", institution: "Harbor Credit Union", shared: true, owner: "Both", icon: "bank" },
  { id: "s2", name: "Visa Signature", institution: "Northstar Card", shared: true, owner: "Both", icon: "bank" },
  { id: "s3", name: "Maya’s debit", institution: "Harbor Credit Union", shared: false, owner: "Maya", icon: "bank" },
  { id: "s4", name: "Jordan’s 401(k)", institution: "Keystone Retirement", shared: false, owner: "Jordan", icon: "trend" },
] as const;

export const SHARED_LEDGER = [
  { id: "l1", label: "Harvest Co-op", paidBy: "M", amount: 57.81 },
  { id: "l2", label: "Nori House", paidBy: "J", amount: 42.36 },
  { id: "l3", label: "Electric · September", paidBy: "M", amount: 86.42 },
  { id: "l4", label: "Parkline Garage", paidBy: "J", amount: 18 },
] as const;
