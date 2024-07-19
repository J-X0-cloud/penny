import type { ReactNode } from "react";
import { WebDashboard } from "@/components/dashboard/WebDashboard";
import { SectionHead } from "@/components/ui/SectionHead";

interface WebSectionProps {
  eyebrow: string;
  title: ReactNode;
  body: string;
  children?: ReactNode;
}

export function WebSection({ eyebrow, title, body, children }: WebSectionProps) {
  return (
    <section className="sec sec-tint" id="web">
      <div className="wrap">
        <SectionHead eyebrow={eyebrow} title={title}>
          {body}
        </SectionHead>
        <WebDashboard />
        {children}
      </div>
    </section>
  );
}
