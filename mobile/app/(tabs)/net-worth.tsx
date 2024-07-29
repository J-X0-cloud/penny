import { useState } from "react";
import { Pressable, StyleSheet, Text, View } from "react-native";
import { IconChip } from "@/components/Chips";
import { Icon, type IconName } from "@/components/Icon";
import { NetWorthChart } from "@/components/NetWorthChart";
import { Pill } from "@/components/Pill";
import { Row } from "@/components/Row";
import { Screen } from "@/components/Screen";
import { ScreenHeader } from "@/components/ScreenHeader";
import { colors, fonts } from "@/constants/theme";
import { netWorthHistory } from "@/lib/data";
import { groupTotals, netWorth, netWorthQuarter } from "@/lib/finance";
import { formatPercent, formatWhole } from "@/lib/money";
import type { AccountGroup } from "@/lib/types";

const GROUP_ICON: Record<AccountGroup, IconName> = {
  Cash: "wallet",
  Investments: "trend",
  "Other assets": "car",
  Liabilities: "card",
};

/** Monthly snapshots shown per range; "All" is the full history kept on this device. */
const RANGES = { "1M": 2, "3M": 4, "1Y": 12, All: netWorthHistory.length } as const;
type Range = keyof typeof RANGES;

export default function NetWorthScreen() {
  const [range, setRange] = useState<Range>("1Y");
  const groups = groupTotals();

  return (
    <Screen>
      <ScreenHeader
        eyebrow="All accounts · updated 12m ago"
        title="Net worth"
        trailing={
          <Pill label="Filter accounts">
            <Icon name="sliders" color={colors.ink} size={16} />
          </Pill>
        }
      />

      <View>
        <Text style={styles.total}>{formatWhole(netWorth)}</Text>
        <View style={styles.delta}>
          <Icon name="up" color={colors.green} size={16} strokeWidth={2.2} />
          <Text style={styles.deltaValue}>{formatWhole(netWorthQuarter.change)}</Text>
          <Text style={styles.deltaNote}>({formatPercent(netWorthQuarter.pct, 1)}) past 3 months</Text>
        </View>
      </View>

      <NetWorthChart values={netWorthHistory.slice(-RANGES[range])} />

      <View style={styles.ranges}>
        {(Object.keys(RANGES) as Range[]).map((key) => (
          <Pressable
            key={key}
            onPress={() => setRange(key)}
            style={[styles.range, key === range && styles.rangeOn]}
            accessibilityRole="button"
            accessibilityState={{ selected: key === range }}
          >
            <Text style={[styles.rangeText, key === range && styles.rangeTextOn]}>{key}</Text>
          </Pressable>
        ))}
      </View>

      <View>
        {groups.map(({ group, total, count }, i) => (
          <Row
            key={group}
            last={i === groups.length - 1}
            leading={<IconChip icon={GROUP_ICON[group]} />}
            title={group}
            subtitle={`${count} account${count > 1 ? "s" : ""}`}
            amount={formatWhole(total)}
            negative={total < 0}
          />
        ))}
      </View>
    </Screen>
  );
}

const styles = StyleSheet.create({
  total: { fontFamily: fonts.serif, fontSize: 38, letterSpacing: -0.8, color: colors.ink },
  delta: { flexDirection: "row", alignItems: "center", gap: 4 },
  deltaValue: { fontFamily: fonts.sansSemi, fontSize: 14, color: colors.green },
  deltaNote: { fontFamily: fonts.sans, fontSize: 13, color: colors.muted },
  ranges: { flexDirection: "row", backgroundColor: colors.line2, borderRadius: 12, padding: 3 },
  range: { flex: 1, alignItems: "center", paddingVertical: 6, borderRadius: 9 },
  rangeOn: { backgroundColor: colors.paper, shadowColor: colors.ink, shadowOpacity: 0.08, shadowRadius: 3, shadowOffset: { width: 0, height: 1 } },
  rangeText: { fontFamily: fonts.sansSemi, fontSize: 13, color: colors.muted },
  rangeTextOn: { color: colors.ink },
});
