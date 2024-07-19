import Image from "next/image";
import { Icon } from "@/components/ui/Icon";

export function RuleCard() {
  return (
    <div className="fcard fc-rule">
      <Image src="/images/cat-groceries.webp" alt="" width={56} height={56} />
      <div className="grow">
        <small>New rule learned</small>
        <b>Harvest Co-op &rarr; Groceries</b>
        <small>Applied to 14 past transactions</small>
      </div>
      <span className="tagc v">
        <Icon name="sparkle" />
        Auto
      </span>
    </div>
  );
}
