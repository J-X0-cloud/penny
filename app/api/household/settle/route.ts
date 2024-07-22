import { NextResponse } from "next/server";
import { z } from "zod";
import { jordanOwes } from "@/lib/finance";

const SettleUp = z.object({
  from: z.enum(["M", "J"]),
  to: z.enum(["M", "J"]),
  amount: z.number().positive().multipleOf(0.01),
  method: z.enum(["transfer", "cash", "other"]).default("transfer"),
});

export async function POST(request: Request) {
  const parsed = SettleUp.safeParse(await request.json().catch(() => null));
  if (!parsed.success) {
    return NextResponse.json({ error: parsed.error.flatten().fieldErrors }, { status: 422 });
  }
  const { from, to, amount, method } = parsed.data;
  if (from === to) {
    return NextResponse.json({ error: "Choose two different members" }, { status: 422 });
  }

  const outstanding = from === "J" ? jordanOwes : 0;
  const remaining = Math.max(0, Math.round((outstanding - amount) * 100) / 100);
  return NextResponse.json({
    settlement: { from, to, amount, method, recordedAt: new Date().toISOString() },
    balance: { remaining, settled: remaining === 0 },
  });
}
