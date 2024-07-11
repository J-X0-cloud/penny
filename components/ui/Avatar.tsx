import clsx from "clsx";
import type { MemberInitial } from "@/types";

export function Avatar({ who, small }: { who: MemberInitial; small?: boolean }) {
  return <span className={clsx("av", small && "sm", `av-${who.toLowerCase()}`)}>{who}</span>;
}

export function CoupleAvatars({ small }: { small?: boolean }) {
  return (
    <span className="avs">
      <Avatar who="M" small={small} />
      <Avatar who="J" small={small} />
    </span>
  );
}
