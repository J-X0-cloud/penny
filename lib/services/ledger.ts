import type { Prisma } from "@prisma/client";
import { CATEGORIES, TRANSACTIONS } from "@/lib/data/household";
import { db, hasDatabase } from "@/lib/db";
import type { CategoryKey, Transaction } from "@/types";

export interface TransactionQuery {
  category?: CategoryKey;
  limit?: number;
}

export interface LedgerRepository {
  listTransactions(query: TransactionQuery): Promise<Transaction[]>;
  recategorize(id: string, category: CategoryKey): Promise<Transaction | null>;
}

/** In-memory ledger backed by the sample household. Used in development and on the marketing site. */
class SampleLedger implements LedgerRepository {
  private rows = TRANSACTIONS.map((t) => ({ ...t }));

  async listTransactions({ category, limit = 50 }: TransactionQuery) {
    return this.rows.filter((t) => !category || t.category === category).slice(0, limit);
  }

  async recategorize(id: string, category: CategoryKey) {
    const row = this.rows.find((t) => t.id === id);
    if (!row) return null;
    row.category = category;
    return row;
  }
}

class PrismaLedger implements LedgerRepository {
  async listTransactions({ category, limit = 50 }: TransactionQuery) {
    const rows = await db.transaction.findMany({
      where: { hidden: false, ...(category ? { categoryKey: category } : {}) },
      include: { account: true, paidBy: true },
      orderBy: { postedAt: "desc" },
      take: limit,
    });
    return rows.map(toTransaction);
  }

  async recategorize(id: string, category: CategoryKey) {
    const row = await db.transaction.update({
      where: { id },
      data: { categoryKey: category, reviewed: true },
      include: { account: true, paidBy: true },
    });
    return toTransaction(row);
  }
}

type PrismaTransactionRow = Prisma.TransactionGetPayload<{ include: { account: true; paidBy: true } }>;

function toTransaction(row: PrismaTransactionRow): Transaction {
  return {
    id: row.id,
    merchant: row.merchant,
    category: row.categoryKey as CategoryKey,
    amount: row.amountCents / 100,
    date: row.postedAt.toLocaleDateString("en-US", { month: "short", day: "numeric" }),
    account: row.account.name,
    paidBy: row.paidBy?.initial === "J" ? "J" : "M",
  };
}

export const CATEGORY_KEYS = CATEGORIES.map((c) => c.key) as [CategoryKey, ...CategoryKey[]];

export const ledger: LedgerRepository = hasDatabase ? new PrismaLedger() : new SampleLedger();
