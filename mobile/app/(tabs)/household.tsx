import * as Haptics from "expo-haptics";
import { Image } from "expo-image";
import { useState } from "react";
import { Alert, Pressable, StyleSheet, Text, View } from "react-native";
import { CoupleAvatars } from "@/components/Avatar";
import { Card } from "@/components/Card";
import { ProgressBar } from "@/components/ProgressBar";
import { Screen } from "@/components/Screen";
import { ScreenHeader } from "@/components/ScreenHeader";
import { SectionTitle } from "@/components/SectionTitle";
import { colors, fonts, members } from "@/constants/theme";
import { goals, period, sharedSpend } from "@/lib/data";
import { jordanOwes, mayaShare, sharedTotal } from "@/lib/finance";
import { formatMoney, formatWhole } from "@/lib/money";

function promptNewGoal() {
  Alert.alert("New shared goal", "Set a target and a date, and Penny works out the monthly amount for both of you.");
}

export default function HouseholdScreen() {
  const [settled, setSettled] = useState(false);

  function settleUp() {
    void Haptics.notificationAsync(Haptics.NotificationFeedbackType.Success);
    setSettled(true);
  }

  return (
    <Screen>
      <ScreenHeader eyebrow={`${members.M.name} & ${members.J.name}`} title="Household" trailing={<CoupleAvatars />} />

      <Card>
        <Text style={styles.label}>Shared spending · {period.month}</Text>
        <Text style={styles.total}>{formatMoney(sharedTotal)}</Text>
        <View style={styles.split}>
          <View style={[styles.splitM, { flex: mayaShare }]} />
          <View style={[styles.splitJ, { flex: 1 - mayaShare }]} />
        </View>
        <View style={styles.splitLegend}>
          <Text style={styles.legendText}>
            <Text style={{ color: colors.violet }}>● </Text>
            {members.M.name} {formatWhole(sharedSpend.M)}
          </Text>
          <Text style={styles.legendText}>
            <Text style={{ color: colors.copper }}>● </Text>
            {members.J.name} {formatWhole(sharedSpend.J)}
          </Text>
        </View>
      </Card>

      <View style={styles.settle}>
        <View style={styles.settleText}>
          <Text style={styles.settleLabel}>Split 50 / 50</Text>
          <Text style={styles.settleValue}>
            {settled ? "All square this month" : `${members.J.name} owes you ${formatMoney(jordanOwes)}`}
          </Text>
        </View>
        <Pressable
          style={[styles.settleButton, settled && styles.settleDone]}
          onPress={settleUp}
          disabled={settled}
          accessibilityRole="button"
        >
          <Text style={styles.settleButtonText}>{settled ? "Settled" : "Settle up"}</Text>
        </Pressable>
      </View>

      <View>
        <SectionTitle title="Shared goals" action={{ label: "Add", onPress: promptNewGoal }} />
        {goals.slice(0, 4).map((goal) => {
          const fraction = goal.saved / goal.target;
          return (
            <View key={goal.id} style={styles.goal}>
              <Image source={goal.image} style={styles.goalImage} contentFit="cover" />
              <View style={styles.goalBody}>
                <View style={styles.goalHead}>
                  <Text style={styles.goalName}>{goal.name}</Text>
                  <Text style={styles.goalPct}>{Math.round(fraction * 100)}%</Text>
                </View>
                <ProgressBar fraction={fraction} color={colors.copper} />
                <Text style={styles.goalMeta}>
                  {formatWhole(goal.saved)} of {formatWhole(goal.target)} · {goal.note}
                </Text>
              </View>
            </View>
          );
        })}
      </View>
    </Screen>
  );
}

const styles = StyleSheet.create({
  label: { fontFamily: fonts.sans, fontSize: 13, color: colors.muted },
  total: { fontFamily: fonts.serif, fontSize: 32, letterSpacing: -0.6, color: colors.ink, marginVertical: 4 },
  split: { flexDirection: "row", height: 10, borderRadius: 6, overflow: "hidden", gap: 3, marginTop: 4 },
  splitM: { backgroundColor: colors.violet, borderRadius: 6 },
  splitJ: { backgroundColor: colors.copper, borderRadius: 6 },
  splitLegend: { flexDirection: "row", justifyContent: "space-between", marginTop: 8 },
  legendText: { fontFamily: fonts.sansMedium, fontSize: 12.5, color: colors.ink2 },
  settle: {
    flexDirection: "row",
    alignItems: "center",
    gap: 12,
    backgroundColor: colors.violetLight,
    borderRadius: 18,
    paddingVertical: 12,
    paddingHorizontal: 14,
  },
  settleText: { flex: 1 },
  settleLabel: { fontFamily: fonts.sans, fontSize: 12, color: colors.violetDark },
  settleValue: { fontFamily: fonts.sansSemi, fontSize: 15, color: colors.ink, marginTop: 1 },
  settleButton: { backgroundColor: colors.violet, borderRadius: 999, paddingHorizontal: 16, paddingVertical: 9 },
  settleDone: { backgroundColor: colors.green },
  settleButtonText: { fontFamily: fonts.sansSemi, fontSize: 13, color: "#FFFFFF" },
  goal: { flexDirection: "row", gap: 12, alignItems: "flex-start", paddingVertical: 8 },
  goalImage: { width: 46, height: 46, borderRadius: 12 },
  goalBody: { flex: 1 },
  goalHead: { flexDirection: "row", justifyContent: "space-between" },
  goalName: { fontFamily: fonts.sansSemi, fontSize: 15, color: colors.ink },
  goalPct: { fontFamily: fonts.sansSemi, fontSize: 13, color: colors.copper },
  goalMeta: { fontFamily: fonts.sans, fontSize: 12, color: colors.muted },
});
