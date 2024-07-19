import type { ComponentType } from "react";
import type { ScreenKey } from "@/lib/data/preview";
import { BillsScreen } from "./BillsScreen";
import { BudgetsScreen } from "./BudgetsScreen";
import { HomeScreen } from "./HomeScreen";
import { HouseholdScreen } from "./HouseholdScreen";
import { NetWorthScreen } from "./NetWorthScreen";

export const SCREEN_COMPONENTS: Record<ScreenKey, ComponentType> = {
  home: HomeScreen,
  budgets: BudgetsScreen,
  bills: BillsScreen,
  networth: NetWorthScreen,
  household: HouseholdScreen,
};
