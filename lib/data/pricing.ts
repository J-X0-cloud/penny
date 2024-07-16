import type { FaqItem, Plan } from "@/types";
import { CONTACT_EMAIL } from "./site";

export const PLANS: Plan[] = [
  {
    id: "penny",
    name: "Penny",
    description: "For one person and all their accounts.",
    price: "$79",
    period: "/year",
    alt: "That’s $6.58 a month, or $8.99 billed monthly",
    features: ["Unlimited accounts", "Budgets, rollovers & rules", "Recurring bills & alerts", "Net worth & investments", "iPhone and web"],
    ctaHref: `mailto:${CONTACT_EMAIL}?subject=Penny%20trial`,
  },
  {
    id: "household",
    name: "Household",
    description: "For two people sharing a home and some of their money.",
    price: "$119",
    period: "/year",
    alt: "That’s $9.92 a month, or $12.99 billed monthly",
    features: ["Everything in Penny", "Two separate logins", "Shared & private accounts", "Split tracking & settle up", "Shared goals"],
    ctaHref: `mailto:${CONTACT_EMAIL}?subject=Penny%20Household%20trial`,
    featured: true,
  },
];

export const PRICE_TEASERS = [
  { name: "Penny", monthly: "$6.58", note: "$79 billed yearly · 1 person" },
  { name: "Household", monthly: "$9.92", note: "$119 billed yearly · 2 people", highlight: true },
] as const;

export const COMPARE_ROWS: { feature: string; penny: boolean; household: boolean }[] = [
  { feature: "Automatic categories & rules", penny: true, household: true },
  { feature: "Budgets with rollovers", penny: true, household: true },
  { feature: "Recurring bills & price alerts", penny: true, household: true },
  { feature: "Net worth & investments", penny: true, household: true },
  { feature: "iPhone and web apps", penny: true, household: true },
  { feature: "CSV export", penny: true, household: true },
  { feature: "Second login", penny: false, household: true },
  { feature: "Shared accounts & split tracking", penny: false, household: true },
  { feature: "Shared goals", penny: false, household: true },
];

export const PRICING_FAQ: FaqItem[] = [
  {
    question: "How does the free trial work?",
    answer:
      "Every new account gets 14 days of the full product. You can explore sample data before connecting anything, and nothing is charged until the trial ends.",
  },
  {
    question: "Which banks does Penny support?",
    answer:
      "Most US banks, credit unions, credit cards, brokerages and retirement providers. You can also add manual accounts for anything we can’t connect.",
  },
  {
    question: "Can Penny move my money?",
    answer: "No. Connections are read-only. Penny can see balances and transactions but cannot make transfers or payments.",
  },
  {
    question: "Why isn’t Penny free?",
    answer:
      "Free finance apps are usually paid for by ads or by selling insights about your spending. Charging a fair subscription keeps our incentives lined up with yours.",
  },
  {
    question: "Can I switch plans or cancel?",
    answer:
      "Yes. Upgrade to Household, downgrade or cancel from Settings at any time. Yearly plans are refunded pro rata within the first 30 days.",
  },
  { question: "Can I take my data with me?", answer: "Always. Export every transaction, budget and balance history to CSV from the web app." },
];
