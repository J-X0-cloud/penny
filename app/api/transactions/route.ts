import { NextResponse, type NextRequest } from "next/server";
import { z } from "zod";
import { CATEGORY_KEYS, ledger } from "@/lib/services/ledger";

const ListQuery = z.object({
  category: z.enum(CATEGORY_KEYS).optional(),
  limit: z.coerce.number().int().min(1).max(200).optional(),
});

export async function GET(request: NextRequest) {
  const parsed = ListQuery.safeParse(Object.fromEntries(request.nextUrl.searchParams));
  if (!parsed.success) {
    return NextResponse.json({ error: parsed.error.flatten().fieldErrors }, { status: 400 });
  }
  const transactions = await ledger.listTransactions(parsed.data);
  return NextResponse.json({ transactions });
}

const Recategorize = z.object({
  id: z.string().min(1),
  category: z.enum(CATEGORY_KEYS),
});

/** Fix a category from the review queue; the web and iPhone apps both call this. */
export async function PATCH(request: Request) {
  const parsed = Recategorize.safeParse(await request.json().catch(() => null));
  if (!parsed.success) {
    return NextResponse.json({ error: parsed.error.flatten().fieldErrors }, { status: 422 });
  }
  const updated = await ledger.recategorize(parsed.data.id, parsed.data.category);
  if (!updated) return NextResponse.json({ error: "Transaction not found" }, { status: 404 });
  return NextResponse.json({ transaction: updated });
}
