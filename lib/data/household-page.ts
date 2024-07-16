import type { FaqItem, Feature } from "@/types";

export const SETUP_STEPS: Feature[] = [
  { icon: "mail", title: "Invite", body: "Send an invite from Settings. Your partner signs in on their own phone with their own login." },
  { icon: "eye", title: "Choose what to share", body: "Pick which accounts join the household. Everything else stays visible to its owner only." },
  { icon: "split", title: "Set the split", body: "Even, by income, or custom per category. Penny keeps a running settle-up balance." },
];

export const HOUSEHOLD_FAQ: FaqItem[] = [
  {
    question: "Can my partner see my personal accounts?",
    answer:
      "No. Only accounts you mark as shared appear in the household view. Private accounts, their balances and their transactions stay visible to you alone.",
  },
  { question: "Do we both need to pay?", answer: "No. The Household plan covers two people with separate logins on one subscription." },
  {
    question: "What if we split some things differently?",
    answer:
      "Set a default split and override it per category or per transaction. Rent can be by income while groceries stay 50/50.",
  },
  {
    question: "Can roommates use it?",
    answer:
      "Yes. Household works for any two people sharing costs, whether that’s a partner, a roommate or a family member.",
  },
];
