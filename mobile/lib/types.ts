import type { ImageSourcePropType } from "react-native";
import type { IconName } from "@/components/Icon";

export type CategoryKey =
  | "groceries"
  | "dining"
  | "home"
  | "transport"
  | "shopping"
  | "fun"
  | "pets"
  | "health"
  | "coffee";

export interface Category {
  key: CategoryKey;
  label: string;
  icon: IconName;
  fg: string;
  bg: string;
  spent: number;
  budget: number;
  rollover: number;
}

export type Member = "M" | "J";

export interface Transaction {
  id: string;
  merchant: string;
  category: CategoryKey;
  amount: number;
  date: string;
  account: string;
  paidBy: Member;
}

export interface Bill {
  id: string;
  name: string;
  icon: IconName;
  amount: number;
  due: string;
  note: string;
  priceChange?: number;
}

export type AccountGroup = "Cash" | "Investments" | "Other assets" | "Liabilities";

export interface Account {
  id: string;
  group: AccountGroup;
  name: string;
  institution: string;
  balance: number;
  updated: string;
}

export interface Goal {
  id: string;
  name: string;
  image: ImageSourcePropType;
  saved: number;
  target: number;
  note: string;
}
