import type { Feature, IconLabel, Testimonial } from "@/types";

export const TRUST_POINTS: IconLabel[] = [
  { icon: "lock", label: "Read-only bank connections" },
  { icon: "face", label: "Face ID lock on every open" },
  { icon: "ban", label: "No ads. No selling your data." },
  { icon: "download", label: "Export to CSV anytime" },
];

export const HERO_FLOATS = [
  { className: "f1", image: "/images/goal-home.webp", title: "Down payment", note: "$38,400 saved" },
  { className: "f2", image: "/images/goal-trip.webp", title: "Yosemite in May", note: "64% there" },
  { className: "f3", image: "/images/cat-groceries.webp", title: "Groceries", note: "$101.80 left" },
  { className: "f4", image: "/images/goal-date.webp", title: "Date night", note: "Rolled over $42" },
] as const;

export const HOUSEHOLD_TICKS: IconLabel[] = [
  { icon: "eyeoff", label: "Private accounts stay private, always" },
  { icon: "split", label: "Fair splits: 50/50, by income, or custom" },
  { icon: "target", label: "Shared goals with automatic transfers" },
];

export const TESTIMONIALS: Testimonial[] = [
  {
    quote:
      "I used to reconcile our spending in a spreadsheet every Sunday night. Now I clear the review queue with my coffee and I’m done in two minutes.",
    name: "Dana R.",
    location: "Portland, OR",
  },
  {
    quote:
      "The household view ended the “did you pay the electric?” texts. We each keep our own cards private and share the bills that are actually shared.",
    name: "Marcus T.",
    location: "Austin, TX",
  },
  {
    quote:
      "Rollovers are the feature I didn’t know I needed. Leftover fun money quietly builds toward a trip instead of disappearing.",
    name: "Priya S.",
    location: "Oakland, CA",
  },
];

export const PLATFORMS = [
  { icon: "phone", title: "iPhone", body: "iOS 17 and later · widgets for spending and bills" },
  { icon: "monitor", title: "Web", body: "Any modern browser · built for budgeting sessions" },
  { icon: "users", title: "Household", body: "Two logins, one shared view" },
] as const satisfies readonly Feature[];
