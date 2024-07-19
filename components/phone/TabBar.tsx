import clsx from "clsx";
import { Icon } from "@/components/ui/Icon";
import { SCREENS, type ScreenKey } from "@/lib/data/preview";

interface TabBarProps {
  active: ScreenKey;
  onSelect?: (key: ScreenKey) => void;
}

export function TabBar({ active, onSelect }: TabBarProps) {
  return (
    <nav className="ps-tabs" aria-label="App sections">
      {SCREENS.map((screen) => {
        const className = clsx("tb", screen.key === active && "on");
        const content = (
          <>
            <Icon name={screen.icon} />
            <i>{screen.tab}</i>
          </>
        );
        return onSelect ? (
          <button key={screen.key} type="button" className={className} onClick={() => onSelect(screen.key)}>
            {content}
          </button>
        ) : (
          <span key={screen.key} className={className}>
            {content}
          </span>
        );
      })}
    </nav>
  );
}
