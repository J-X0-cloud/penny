"use client";

import clsx from "clsx";
import { useCallback, useEffect, useRef, useState } from "react";
import type { TouchEvent } from "react";
import { StatusBar } from "@/components/phone/StatusBar";
import { TabBar } from "@/components/phone/TabBar";
import { SCREEN_COMPONENTS } from "@/components/phone/screens";
import { Icon } from "@/components/ui/Icon";
import { SCREENS, type ScreenKey } from "@/lib/data/preview";

const SWIPE_THRESHOLD = 40;

export function PhonePreview() {
  const [current, setCurrent] = useState(0);
  const touchX = useRef<number | null>(null);
  const count = SCREENS.length;

  const go = useCallback((i: number) => setCurrent(((i % count) + count) % count), [count]);
  const goTo = useCallback((key: ScreenKey) => go(SCREENS.findIndex((s) => s.key === key)), [go]);

  useEffect(() => {
    function onKey(event: KeyboardEvent) {
      if (event.key === "ArrowRight") setCurrent((i) => (i + 1) % count);
      if (event.key === "ArrowLeft") setCurrent((i) => (i - 1 + count) % count);
    }
    document.addEventListener("keydown", onKey);
    return () => document.removeEventListener("keydown", onKey);
  }, [count]);

  function onTouchStart(event: TouchEvent) {
    touchX.current = event.touches[0]?.clientX ?? null;
  }

  function onTouchEnd(event: TouchEvent) {
    const start = touchX.current;
    const end = event.changedTouches[0]?.clientX;
    touchX.current = null;
    if (start === null || end === undefined) return;
    const dx = end - start;
    if (Math.abs(dx) > SWIPE_THRESHOLD) go(current + (dx < 0 ? 1 : -1));
  }

  return (
    <section className="pv">
      <div className="wrap pv-grid">
        <div className="pv-tabs" role="group" aria-label="Choose a screen">
          {SCREENS.map((screen, i) => (
            <button
              key={screen.key}
              type="button"
              className={clsx("pv-tab", i === current && "on")}
              aria-pressed={i === current}
              onClick={() => go(i)}
            >
              <span className="n">0{i + 1}</span>
              <span>
                <b>{screen.title}</b>
                <small>{screen.description}</small>
              </span>
            </button>
          ))}
        </div>

        <div className="pv-stage">
          <div className="halo" />
          <div className="phone pv-phone" aria-live="polite" onTouchStart={onTouchStart} onTouchEnd={onTouchEnd}>
            <div className="scr">
              <span className="island" />
              <StatusBar />
              <div className="screens">
                {SCREENS.map((screen, i) => {
                  const Screen = SCREEN_COMPONENTS[screen.key];
                  return (
                    <div key={screen.key} className={clsx("screen", i === current && "on")} aria-hidden={i !== current}>
                      <div className="ps-body">
                        <Screen />
                      </div>
                      <TabBar active={screen.key} onSelect={goTo} />
                    </div>
                  );
                })}
              </div>
              <span className="homebar" />
            </div>
          </div>
          <div className="pv-ctl">
            <button type="button" className="arr" aria-label="Previous screen" onClick={() => go(current - 1)}>
              <Icon name="chevl" />
            </button>
            <div className="dots">
              {SCREENS.map((screen, i) => (
                <button
                  key={screen.key}
                  type="button"
                  className={clsx("dotb", i === current && "on")}
                  aria-label={`Show ${screen.tab} screen`}
                  onClick={() => go(i)}
                />
              ))}
            </div>
            <button type="button" className="arr" aria-label="Next screen" onClick={() => go(current + 1)}>
              <Icon name="chev" />
            </button>
          </div>
          <p className="pv-note">Sample data · Maya &amp; Jordan&rsquo;s household, September</p>
        </div>
      </div>
    </section>
  );
}
