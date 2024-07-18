const cache = new Map<number, Intl.NumberFormat>();

function formatter(decimals: number) {
  let f = cache.get(decimals);
  if (!f) {
    f = new Intl.NumberFormat("en-US", { minimumFractionDigits: decimals, maximumFractionDigits: decimals });
    cache.set(decimals, f);
  }
  return f;
}

/** 1708.42 -> "$1,708.42"; -11240.18 -> "-$11,240.18"; money(2250, 0) -> "$2,250" */
export function money(value: number, decimals = 2): string {
  const body = formatter(decimals).format(Math.abs(value));
  return (value < 0 ? "-$" : "$") + body;
}

/** 38400 -> "$38.4k" */
export function moneyK(value: number): string {
  return `$${formatter(1).format(value / 1000)}k`;
}

/** Splits a positive amount into whole dollars and cents for the large display figures. */
export function splitMoney(value: number): { dollars: string; cents: string } {
  const [dollars = "0", cents = "00"] = formatter(2).format(Math.abs(value)).split(".");
  return { dollars: `$${dollars}`, cents };
}

export function percent(value: number, decimals = 0): string {
  return `${value.toFixed(decimals)}%`;
}
