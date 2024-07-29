/**
 * Money formatting shared by every screen. Amounts are dollars as numbers; the API sends cents and
 * the data layer converts once on the way in.
 */

const formatters = new Map<number, Intl.NumberFormat>();

function grouped(decimals: number): Intl.NumberFormat {
  let f = formatters.get(decimals);
  if (!f) {
    f = new Intl.NumberFormat("en-US", { minimumFractionDigits: decimals, maximumFractionDigits: decimals });
    formatters.set(decimals, f);
  }
  return f;
}

/** 1708.42 -> "$1,708.42"; -11240.18 -> "-$11,240.18" */
export function formatMoney(value: number, decimals = 2): string {
  return `${value < 0 ? "-" : ""}$${grouped(decimals).format(Math.abs(value))}`;
}

/** Whole dollars: 2250 -> "$2,250" */
export function formatWhole(value: number): string {
  return formatMoney(value, 0);
}

/** 38400 -> "$38.4k" */
export function formatCompact(value: number): string {
  return `$${grouped(1).format(value / 1000)}k`;
}

/** Splits 1708.42 into { dollars: "$1,708", cents: "42" } for the large serif figures. */
export function splitDollars(value: number): { dollars: string; cents: string } {
  const [dollars = "0", cents = "00"] = grouped(2).format(Math.abs(value)).split(".");
  return { dollars: `${value < 0 ? "-" : ""}$${dollars}`, cents };
}

/** 3.857 -> "3.9%" */
export function formatPercent(value: number, decimals = 0): string {
  return `${value.toFixed(decimals)}%`;
}

export function centsToDollars(cents: number): number {
  return Math.round(cents) / 100;
}
