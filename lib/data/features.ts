import type { Feature } from "@/types";

export const FEATURE_ANCHORS = [
  { href: "#transactions", label: "Transactions" },
  { href: "#budgets", label: "Budgets" },
  { href: "#recurring", label: "Recurring" },
  { href: "#networth", label: "Net worth" },
  { href: "#security", label: "Security" },
] as const;

export const TRANSACTION_FEATURES: Feature[] = [
  { icon: "sparkle", title: "Smart categories", body: "Suggestions get sharper with every fix." },
  { icon: "tag", title: "Rules & renames", body: "Clean up cryptic merchant names for good." },
  { icon: "split", title: "Split a purchase", body: "One receipt, several categories." },
];

export const BUDGET_FEATURES: Feature[] = [
  { icon: "pie", title: "Category budgets", body: "Monthly limits with a live progress ring." },
  { icon: "repeat", title: "Rollovers", body: "Leftover money carries into next month." },
  { icon: "bell", title: "Pace alerts", body: "A nudge when a category runs hot." },
];

export const RECURRING_FEATURES: Feature[] = [
  { icon: "calendar", title: "Bill calendar", body: "What’s due, when, and from which account." },
  { icon: "trend", title: "Price-change flags", body: "Know the moment a subscription goes up." },
  { icon: "inbox", title: "Forgotten subscriptions", body: "Spot the ones you stopped using." },
];

export const NET_WORTH_FEATURES: Feature[] = [
  { icon: "trend", title: "Twelve-month history", body: "Monthly snapshots, automatically." },
  { icon: "pie", title: "Allocation", body: "See how diversified you really are." },
  { icon: "wallet", title: "Manual assets", body: "Cars, collectibles, money owed to you." },
];

export const SECURITY_FEATURES: Feature[] = [
  {
    icon: "lock",
    title: "Read-only by design",
    body: "Penny connects through a regulated data aggregator with read-only access. Nobody, including us, can move money from your accounts.",
  },
  {
    icon: "shieldck",
    title: "Encrypted in transit and at rest",
    body: "Every connection uses TLS and stored data is encrypted. Your bank login is never stored on Penny’s servers.",
  },
  { icon: "face", title: "Face ID and passcode", body: "Lock the app on every open, and hide balances from the home screen with one tap." },
  { icon: "ban", title: "No ads, no data sales", body: "We charge a subscription so we never have to sell your spending habits to anyone." },
];
