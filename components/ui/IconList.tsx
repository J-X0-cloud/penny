import type { IconLabel } from "@/types";
import { Icon } from "./Icon";

export function IconList({ items }: { items: IconLabel[] }) {
  return (
    <ul className="ticks">
      {items.map((item) => (
        <li key={item.label}>
          <Icon name={item.icon} />
          {item.label}
        </li>
      ))}
    </ul>
  );
}
