"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useEffect, useRef } from "react";
import { Wordmark } from "@/components/brand/Logo";
import { NAV } from "@/lib/data/site";

export function Header() {
  const pathname = usePathname();
  const menuRef = useRef<HTMLDetailsElement>(null);

  useEffect(() => {
    if (menuRef.current) menuRef.current.open = false;
  }, [pathname]);

  const links = NAV.map((item) => (
    <Link key={item.href} href={item.href} aria-current={pathname.startsWith(item.href) ? "page" : undefined}>
      {item.label}
    </Link>
  ));

  return (
    <header className="site-head">
      <div className="wrap head-row">
        <Wordmark />
        <nav className="nav" aria-label="Main">
          {links}
        </nav>
        <div className="head-cta">
          <Link className="login" href="/app">
            Log in
          </Link>
          <Link className="btn btn-primary" href="/pricing">
            Start free trial
          </Link>
        </div>
        <details className="mnav" ref={menuRef}>
          <summary aria-label="Open menu">
            <span />
            <span />
            <span />
          </summary>
          <div className="mnav-panel">
            {links}
            <Link className="btn btn-primary" href="/pricing">
              Start free trial
            </Link>
          </div>
        </details>
      </div>
    </header>
  );
}
