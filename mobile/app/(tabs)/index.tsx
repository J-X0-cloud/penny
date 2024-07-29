import { router } from "expo-router";
import { StyleSheet, Text, View } from "react-native";
import Svg, { Defs, LinearGradient, Rect, Stop } from "react-native-svg";
import { Avatar } from "@/components/Avatar";
import { BillRow } from "@/components/BillRow";
import { CategoryChip } from "@/components/Chips";
import { Row } from "@/components/Row";
import { Screen } from "@/components/Screen";
import { ScreenHeader } from "@/components/ScreenHeader";
import { CountBadge, SectionTitle } from "@/components/SectionTitle";
import { SpendChart } from "@/components/SpendChart";
import { colors, fonts, radius } from "@/constants/theme";
import { bills, period, reviewQueueCount, transactions } from "@/lib/data";
import { budget, categoryByKey, spent, underPace } from "@/lib/finance";
import { formatMoney, formatWhole, splitDollars } from "@/lib/money";

export default function HomeScreen() {
  const { dollars, cents } = splitDollars(spent);
  const upcoming = bills.slice(0, 2);
  const toReview = transactions.slice(0, 2);

  return (
    <Screen>
      <ScreenHeader eyebrow={period.today} title="Good morning, Maya" trailing={<Avatar who="M" />} />

      <View style={styles.hero}>
        <Svg style={StyleSheet.absoluteFill}>
          <Defs>
            <LinearGradient id="hero" x1="0" y1="0" x2="1" y2="1">
              <Stop offset="0" stopColor={colors.heroTop} />
              <Stop offset="1" stopColor={colors.heroBottom} />
            </LinearGradient>
          </Defs>
          <Rect width="100%" height="100%" fill="url(#hero)" />
        </Svg>
        <View style={styles.heroHead}>
          <Text style={styles.heroLabel}>Spent in {period.month}</Text>
          <Text style={styles.heroPill}>Household</Text>
        </View>
        <Text style={styles.big}>
          {dollars}
          <Text style={styles.bigCents}>.{cents}</Text>
        </Text>
        <Text style={styles.sub}>
          of {formatWhole(budget)} budget · <Text style={styles.subStrong}>{formatWhole(underPace)} under pace</Text>
        </Text>
        <View style={styles.chart}>
          <SpendChart />
        </View>
        <View style={styles.axis}>
          <Text style={styles.axisText}>{period.short} 1</Text>
          <Text style={styles.axisText}>15</Text>
          <Text style={styles.axisText}>{period.days}</Text>
        </View>
      </View>

      <View>
        <SectionTitle title="Upcoming bills" action={{ label: "See all", onPress: () => router.push("/bills") }} />
        {upcoming.map((bill, i) => (
          <BillRow key={bill.id} bill={bill} last={i === upcoming.length - 1} />
        ))}
      </View>

      <View>
        <SectionTitle title="To review" badge={<CountBadge count={reviewQueueCount} />} />
        {toReview.map((txn, i) => (
          <Row
            key={txn.id}
            last={i === toReview.length - 1}
            leading={<CategoryChip category={txn.category} />}
            title={txn.merchant}
            subtitle={`${categoryByKey[txn.category].label} · ${txn.date}`}
            amount={formatMoney(txn.amount)}
          />
        ))}
      </View>
    </Screen>
  );
}

const styles = StyleSheet.create({
  hero: { borderRadius: radius.lg, overflow: "hidden", paddingTop: 14, paddingHorizontal: 16, paddingBottom: 10 },
  heroHead: { flexDirection: "row", justifyContent: "space-between", alignItems: "center" },
  heroLabel: { fontFamily: fonts.sans, fontSize: 13, color: "rgba(255,255,255,0.8)" },
  heroPill: {
    overflow: "hidden",
    fontFamily: fonts.sansSemi,
    fontSize: 11,
    color: "#FFFFFF",
    backgroundColor: "rgba(255,255,255,0.16)",
    borderRadius: 999,
    paddingHorizontal: 9,
    paddingVertical: 3,
  },
  big: { fontFamily: fonts.serif, fontSize: 40, letterSpacing: -0.8, color: "#FFFFFF", marginTop: 2 },
  bigCents: { fontSize: 24, color: "rgba(255,255,255,0.7)" },
  sub: { fontFamily: fonts.sans, fontSize: 13, color: "rgba(255,255,255,0.85)" },
  subStrong: { fontFamily: fonts.sansSemi, color: colors.heroAccent },
  chart: { marginTop: 10, marginBottom: 2 },
  axis: { flexDirection: "row", justifyContent: "space-between" },
  axisText: { fontFamily: fonts.sans, fontSize: 11, color: "rgba(255,255,255,0.65)" },
});
