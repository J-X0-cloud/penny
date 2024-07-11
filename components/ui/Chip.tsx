import clsx from "clsx";
import { CATEGORY_BY_KEY } from "@/lib/finance";
import type { CategoryKey } from "@/types";
import { Icon, type IconName } from "./Icon";

type ChipSize = "sm" | undefined;

export function CategoryChip({ category, size }: { category: CategoryKey; size?: ChipSize }) {
  const c = CATEGORY_BY_KEY[category];
  return (
    <span className={clsx("cic", size)} style={{ color: c.fg, background: c.bg }}>
      <Icon name={c.icon} />
    </span>
  );
}

/** Brand-violet chip for bills, accounts and other non-category rows. */
export function IconChip({ icon, size }: { icon: IconName; size?: ChipSize }) {
  return (
    <span className={clsx("cic", size)} style={{ color: "#5B3FD9", background: "#EEE9FD" }}>
      <Icon name={icon} />
    </span>
  );
}
