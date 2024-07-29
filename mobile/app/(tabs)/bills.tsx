import { useMemo, useState } from "react";
import { Pressable, StyleSheet, Text, View } from "react-native";
import { BillRow } from "@/components/BillRow";
import { Card } from "@/components/Card";
import { Icon } from "@/components/Icon";
import { Pill } from "@/components/Pill";
import { Screen } from "@/components/Screen";
import { ScreenHeader } from "@/components/ScreenHeader";
import { colors, fonts } from "@/constants/theme";
import { bills, octoberWeek } from "@/lib/data";
import { billsTotal } from "@/lib/finance";
import { formatMoney } from "@/lib/money";

export default function BillsScreen() {
  const [selectedDay, setSelectedDay] = useState<number | null>(null);
  const priceChange = bills.find((bill) => bill.priceChange);

  const visible = useMemo(() => {
    if (selectedDay === null) return bills.slice(0, 6);
    return bills.filter((bill) => bill.due === `Oct ${selectedDay}`);
  }, [selectedDay]);

  return (
    <Screen>
      <ScreenHeader
        eyebrow={`Next 30 days · ${bills.length} bills`}
        title="Recurring"
        trailing={
          <Pill label="Add a bill">
            <Icon name="plus" color={colors.ink} size={16} />
          </Pill>
        }
      />
      <Text style={styles.total}>{formatMoney(billsTotal)}</Text>

      <Card>
        <Text style={styles.month}>October</Text>
        <View style={styles.week}>
          {octoberWeek.map((d) => {
            const active = selectedDay === d.day;
            return (
              <Pressable
                key={d.day}
                style={[styles.day, active && styles.dayActive]}
                onPress={() => setSelectedDay(active ? null : d.day)}
                accessibilityRole="button"
                accessibilityState={{ selected: active }}
              >
                <Text style={[styles.weekday, active && styles.onActive]}>{d.weekday}</Text>
                <Text style={[styles.dayNum, active && styles.onActiveStrong]}>{d.day}</Text>
                <View style={[styles.dot, !d.due && styles.dotHidden, active && styles.dotActive]} />
              </Pressable>
            );
          })}
        </View>
      </Card>

      {priceChange ? (
        <View style={styles.alert}>
          <Icon name="bell" color={colors.copper} size={20} />
          <View style={styles.alertText}>
            <Text style={styles.alertTitle}>
              {priceChange.name} went up {formatMoney(priceChange.priceChange ?? 0)}
            </Text>
            <Text style={styles.alertBody}>
              Now {formatMoney(priceChange.amount)} a month, starting {priceChange.due}.
            </Text>
          </View>
        </View>
      ) : null}

      <View>
        {visible.length === 0 ? (
          <Text style={styles.empty}>Nothing due on Oct {selectedDay}.</Text>
        ) : (
          visible.map((bill, i) => <BillRow key={bill.id} bill={bill} last={i === visible.length - 1} />)
        )}
      </View>
    </Screen>
  );
}

const styles = StyleSheet.create({
  total: { fontFamily: fonts.serif, fontSize: 38, letterSpacing: -0.8, color: colors.ink },
  month: { fontFamily: fonts.sansSemi, fontSize: 12, color: colors.muted, marginBottom: 6 },
  week: { flexDirection: "row", justifyContent: "space-between" },
  day: { alignItems: "center", width: 40, paddingVertical: 6, borderRadius: 12, gap: 2 },
  dayActive: { backgroundColor: colors.violet },
  weekday: { fontFamily: fonts.sans, fontSize: 11, color: colors.muted },
  dayNum: { fontFamily: fonts.sansSemi, fontSize: 15, color: colors.ink },
  onActive: { color: "rgba(255,255,255,0.75)" },
  onActiveStrong: { color: "#FFFFFF" },
  dot: { width: 5, height: 5, borderRadius: 3, backgroundColor: colors.copper },
  dotHidden: { opacity: 0 },
  dotActive: { backgroundColor: "#FFFFFF" },
  alert: {
    flexDirection: "row",
    gap: 10,
    alignItems: "flex-start",
    backgroundColor: colors.copperLight,
    borderRadius: 16,
    padding: 12,
  },
  alertText: { flex: 1 },
  alertTitle: { fontFamily: fonts.sansSemi, fontSize: 14, color: colors.ink },
  alertBody: { fontFamily: fonts.sans, fontSize: 12.5, color: colors.ink2, marginTop: 2 },
  empty: { fontFamily: fonts.sans, fontSize: 14, color: colors.muted, paddingVertical: 16, textAlign: "center" },
});
