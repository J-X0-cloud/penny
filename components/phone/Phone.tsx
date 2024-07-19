import clsx from "clsx";
import { SCREENS, type ScreenKey } from "@/lib/data/preview";
import { StatusBar } from "./StatusBar";
import { TabBar } from "./TabBar";
import { SCREEN_COMPONENTS } from "./screens";

interface PhoneProps {
  screen: ScreenKey;
  /** Layout modifier from the stylesheet: "front", "back" or "solo". */
  variant?: "front" | "back" | "solo";
}

/** Static phone mockup showing one app screen, used across the marketing pages. */
export function Phone({ screen, variant }: PhoneProps) {
  const Screen = SCREEN_COMPONENTS[screen];
  const tab = SCREENS.find((s) => s.key === screen)?.tab ?? screen;
  return (
    <div className={clsx("phone", variant)} role="img" aria-label={`Penny app, ${tab} screen`}>
      <div className="scr">
        <span className="island" />
        <StatusBar />
        <div className="ps-body">
          <Screen />
        </div>
        <TabBar active={screen} />
        <span className="homebar" />
      </div>
    </div>
  );
}
