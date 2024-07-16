import type { NavLink } from "@/types";

export const CONTACT_EMAIL = "hello@pennyapp.com";

export const SITE = {
  name: "Penny",
  url: "https://pennyapp.com",
  themeColor: "#F7F4EF",
  footerBlurb:
    "Budgets, bills, net worth and a shared household view, on iPhone and the web. Read-only connections, no ads, no selling your data.",
  legal: "© 2026 Penny Money Co.",
  disclaimer: "Penny is a budgeting tool, not a bank. Account connections are read-only.",
} as const;

export const NAV: NavLink[] = [
  { href: "/features", label: "Features" },
  { href: "/household", label: "Household" },
  { href: "/pricing", label: "Pricing" },
  { href: "/app", label: "App preview" },
];

export const FOOTER_COLUMNS: { title: string; links: NavLink[] }[] = [
  { title: "Product", links: NAV },
  {
    title: "Learn",
    links: [
      { href: "/features#budgets", label: "Budgets & rollovers" },
      { href: "/features#recurring", label: "Recurring bills" },
      { href: "/features#networth", label: "Net worth" },
      { href: "/features#security", label: "Security" },
    ],
  },
  {
    title: "Company",
    links: [
      { href: "/pricing#faq", label: "FAQ" },
      { href: `mailto:${CONTACT_EMAIL}`, label: "Contact" },
      { href: "#", label: "Privacy" },
      { href: "#", label: "Terms" },
    ],
  },
];
