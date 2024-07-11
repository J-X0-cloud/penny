import clsx from "clsx";
import type { ReactNode } from "react";

export function Eyebrow({ children, dot }: { children: ReactNode; dot?: boolean }) {
  return (
    <p className="eyebrow">
      {dot && <span className="dot" />}
      {children}
    </p>
  );
}

interface SectionHeadProps {
  eyebrow?: string;
  title: ReactNode;
  children?: ReactNode;
  tone?: "light" | "left";
}

export function SectionHead({ eyebrow, title, children, tone }: SectionHeadProps) {
  return (
    <div className={clsx("sec-h", tone)}>
      {eyebrow && <Eyebrow>{eyebrow}</Eyebrow>}
      <h2>{title}</h2>
      {typeof children === "string" ? <p>{children}</p> : children}
    </div>
  );
}
