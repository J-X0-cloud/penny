import type { IconName } from "@/components/ui/Icon";

export type CategoryKey =
  | "groceries"
  | "dining"
  | "home"
  | "transport"
  | "shopping"
  | "fun"
  | "pets"
  | "health"
  | "coffee";

export interface Category {
  key: CategoryKey;
  label: string;
  icon: IconName;
  /** Foreground and tint used for the category chip. */
  fg: string;
  bg: string;
  spent: number;
  budget: number;
  /** Unspent money carried in from last month. */
  rollover: number;
}

export type MemberInitial = "M" | "J";

export interface Transaction {
  id: string;
  merchant: string;
  category: CategoryKey;
  amount: number;
  date: string;
  account: string;
  paidBy: MemberInitial;
}

export interface Bill {
  id: string;
  name: string;
  icon: IconName;
  amount: number;
  due: string;
  note: string;
  /** Set when the amount changed since the last charge. */
  priceChange?: number;
}

export type AccountGroup = "Cash" | "Investments" | "Other assets" | "Liabilities";

export interface Account {
  id: string;
  group: AccountGroup;
  name: string;
  institution: string;
  balance: number;
  updated: string;
}

export interface Goal {
  id: string;
  name: string;
  image: string;
  saved: number;
  target: number;
  note: string;
}

export interface CashflowMonth {
  month: string;
  income: number;
  spending: number;
}

export interface AllocationSlice {
  label: string;
  percent: number;
  color: string;
}

export interface NavLink {
  href: string;
  label: string;
}

export interface IconLabel {
  icon: IconName;
  label: string;
}

export interface Feature {
  icon: IconName;
  title: string;
  body: string;
}

export interface Testimonial {
  quote: string;
  name: string;
  location: string;
}

export interface FaqItem {
  question: string;
  answer: string;
}

export interface Plan {
  id: "penny" | "household";
  name: string;
  description: string;
  price: string;
  period: string;
  alt: string;
  features: string[];
  ctaHref: string;
  featured?: boolean;
}
