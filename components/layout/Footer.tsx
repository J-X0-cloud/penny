import Link from "next/link";
import { Wordmark } from "@/components/brand/Logo";
import { Icon } from "@/components/ui/Icon";
import { FOOTER_COLUMNS, SITE } from "@/lib/data/site";

export function Footer() {
  return (
    <footer className="site-foot">
      <div className="wrap">
        <div className="foot-grid">
          <div className="foot-brand">
            <Wordmark variant="light" />
            <p>{SITE.footerBlurb}</p>
            <div className="plat">
              <span>
                <Icon name="phone" /> iPhone
              </span>
              <span>
                <Icon name="monitor" /> Web
              </span>
            </div>
          </div>
          {FOOTER_COLUMNS.map((column) => (
            <div key={column.title}>
              <h4>{column.title}</h4>
              {column.links.map((link) =>
                link.href.startsWith("mailto:") ? (
                  <a key={link.label} href={link.href}>
                    {link.label}
                  </a>
                ) : (
                  <Link key={link.label} href={link.href}>
                    {link.label}
                  </Link>
                ),
              )}
            </div>
          ))}
        </div>
        <div className="foot-base">
          <span>{SITE.legal}</span>
          <span>{SITE.disclaimer}</span>
        </div>
      </div>
    </footer>
  );
}
