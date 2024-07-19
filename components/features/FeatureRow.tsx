import clsx from "clsx";
import type { ReactNode } from "react";
import { Icon } from "@/components/ui/Icon";
import { Eyebrow } from "@/components/ui/SectionHead";
import type { Feature } from "@/types";

interface FeatureRowProps {
  id: string;
  eyebrow: string;
  title: ReactNode;
  body: string;
  bullets: Feature[];
  flip?: boolean;
  children: ReactNode;
}

export function FeatureRow({ id, eyebrow, title, body, bullets, flip, children }: FeatureRowProps) {
  return (
    <section className={clsx("frow", flip && "flip")} id={id}>
      <div className="wrap frow-in">
        <div className="copy">
          <Eyebrow>{eyebrow}</Eyebrow>
          <h2>{title}</h2>
          <p>{body}</p>
          <ul className="flist">
            {bullets.map((bullet) => (
              <li key={bullet.title}>
                <Icon name={bullet.icon} />
                <div>
                  <b>{bullet.title}</b>
                  <span>{bullet.body}</span>
                </div>
              </li>
            ))}
          </ul>
        </div>
        <div className="fvis">{children}</div>
      </div>
    </section>
  );
}
