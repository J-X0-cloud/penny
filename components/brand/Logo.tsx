import Link from "next/link";
import clsx from "clsx";
import { useId } from "react";

export function LogoMark() {
  const gradientId = useId();
  return (
    <svg className="logo-mark" viewBox="0 0 36 36" aria-hidden="true">
      <defs>
        <linearGradient id={gradientId} x1="0" y1="0" x2="1" y2="1">
          <stop offset="0" stopColor="#E39A5F" />
          <stop offset="1" stopColor="#B25F2B" />
        </linearGradient>
      </defs>
      <circle cx="18" cy="18" r="17" fill={`url(#${gradientId})`} />
      <circle cx="18" cy="18" r="13.2" fill="none" stroke="#FBE3CC" strokeOpacity=".55" strokeWidth="1" />
      <rect x="12.2" y="11" width="3.8" height="16" rx="1.9" fill="#FFF8F1" />
      <circle cx="20" cy="16.4" r="4.4" fill="none" stroke="#FFF8F1" strokeWidth="3.6" />
    </svg>
  );
}

export function Wordmark({ variant }: { variant?: "light" | "sm" }) {
  return (
    <Link className={clsx("brand", variant)} href="/" aria-label="Penny home">
      <LogoMark />
      <span>penny</span>
    </Link>
  );
}
