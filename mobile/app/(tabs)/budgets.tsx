import { useState } from "react";
import { StyleSheet, Text, View } from "react-native";
import { Card } from "@/components/Card";
import { CategoryChip } from "@/components/Chips";
import { Donut } from "@/components/Donut";
import { Icon } from "@/components/Icon";
import { Pill } from "@/components/Pill";
import { ProgressBar } from "@/components/ProgressBar";
import { Screen } from "@/components/Screen";
import { ScreenHeader } from "@/components/ScreenHeader";
import { colors, fonts } from "@/constants/theme";
import { categories, period } from "@/lib/data";
import { budget, budgetStatus, left, spent, underPace } from "@/lib/finance";
import { formatWhole } from "@/lib/money";

export default function BudgetsScreen() {
  const [showAll, setShowAll] = useState(false);
  const visible = showAll ? categories : categories.slice(0, 6);

  return (
    <Screen>
      <ScreenHeader
        eyebrow="Monthly budget"
        title="Budgets"
        trailing={
          <Pill label="Change month">
            <Text style={styles.pillText}>{period.short}</Text>
            <Icon name="chevd" color={colors.ink} size={15} />
          </Pill>
        }
      />

      <Card style={styles.ringCard}>
        <Donut fraction={spent / budget}>
          <Text style={styles.ringValue}>{formatWhole(left)}</Text>
          <Text style={styles.ringLabel}>left</Text>
        </Donut>
        <View style={styles.legend}>
          <LegendRow swatch={colors.violet} label="Spent" value={formatWhole(spent)} />
          <LegendRow swatch={colors.track} label="Budget" value={formatWhole(budget)} />
          <View style={styles.ok}>
            <Icon name="check" color={colors.green} size={14} />
            <Text style={styles.okText}>{formatWhole(underPace)} under pace</Text>
          </View>
        </View>
      </Card>

      <View>
        {visible.map((category) => {
          const status = budgetStatus(category);
          return (
            <View key={category.key} style={styles.budget}>
              <CategoryChip category={category.key} />
              <View style={styles.budgetBody}>
                <View style={styles.budgetHead}>
                  <Text style={styles.budgetName}>{category.label}</Text>
                  {status.over ? (
                    <Text style={[styles.note, styles.over]}>{formatWhole(category.spent - category.budget)} over</Text>
                  ) : category.rollover ? (
                    <Text style={[styles.note, styles.rollover]}>+{formatWhole(category.rollover)} rollover</Text>
                  ) : (
                    <Text style={styles.note}>{formatWhole(status.remaining)} left</Text>
                  )}
                </View>
                <ProgressBar fraction={status.fraction} color={status.over ? colors.rose : category.fg} />
                <Text style={styles.small}>
                  {formatWhole(category.spent)} of {formatWhole(status.available)}
                </Text>
              </View>
            </View>
          );
        })}
      </View>

      {!showAll ? (
        <Pill onPress={() => setShowAll(true)} label="Show all categories">
          {`Show all ${categories.length} categories`}
        </Pill>
      ) : null}
    </Screen>
  );
}

function LegendRow({ swatch, label, value }: { swatch: string; label: string; value: string }) {
  return (
    <View style={styles.legendRow}>
      <View style={[styles.swatch, { backgroundColor: swatch }]} />
      <Text style={styles.legendLabel}>{label}</Text>
      <Text style={styles.legendValue}>{value}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  pillText: { fontFamily: fonts.sansSemi, fontSize: 13, color: colors.ink },
  ringCard: { flexDirection: "row", alignItems: "center", gap: 18 },
  ringValue: { fontFamily: fonts.serifSemi, fontSize: 20, color: colors.ink },
  ringLabel: { fontFamily: fonts.sans, fontSize: 12, color: colors.muted },
  legend: { flex: 1, gap: 6 },
  legendRow: { flexDirection: "row", alignItems: "center", gap: 7 },
  swatch: { width: 9, height: 9, borderRadius: 3 },
  legendLabel: { fontFamily: fonts.sans, fontSize: 13, color: colors.ink2, flex: 1 },
  legendValue: { fontFamily: fonts.sansSemi, fontSize: 13, color: colors.ink },
  ok: { flexDirection: "row", alignItems: "center", gap: 5 },
  okText: { fontFamily: fonts.sansSemi, fontSize: 13, color: colors.green },
  budget: { flexDirection: "row", gap: 12, alignItems: "flex-start", paddingVertical: 8 },
  budgetBody: { flex: 1 },
  budgetHead: { flexDirection: "row", justifyContent: "space-between", alignItems: "baseline" },
  budgetName: { fontFamily: fonts.sansSemi, fontSize: 15, color: colors.ink },
  note: { fontFamily: fonts.sansMedium, fontSize: 12.5, color: colors.muted },
  over: { color: colors.rose },
  rollover: { color: colors.green },
  small: { fontFamily: fonts.sans, fontSize: 12, color: colors.muted },
});
