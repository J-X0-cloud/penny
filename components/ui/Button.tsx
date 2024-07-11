import Link from "next/link";
import clsx from "clsx";
import type { ReactNode } from "react";
import { Icon } from "./Icon";

interface ButtonProps {
  href: string;
  variant?: "primary" | "line" | "copper" | "line-w";
  size?: "md" | "lg";
  block?: boolean;
  arrow?: boolean;
  children: ReactNode;
}

export function Button({ href, variant = "primary", size = "md", block, arrow, children }: ButtonProps) {
  const className = clsx("btn", `btn-${variant}`, size === "lg" && "btn-lg", block && "btn-block");
  const content = (
    <>
      {children}
      {arrow && <Icon name="arrow" />}
    </>
  );
  return href.startsWith("mailto:") ? (
    <a className={className} href={href}>
      {content}
    </a>
  ) : (
    <Link className={className} href={href}>
      {content}
    </Link>
  );
}
