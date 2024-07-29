import type { ReactNode } from "react";
import { StyleSheet, Text, View } from "react-native";
import { colors, fonts } from "@/constants/theme";

interface RowProps {
  leading: ReactNode;
  title: ReactNode;
  subtitle?: string;
  amount?: string;
  negative?: boolean;
  last?: boolean;
}

/** List row used for transactions, bills and accounts: chip, two lines, right-aligned amount. */
export function Row({ leading, title, subtitle, amount, negative, last }: RowProps) {
  return (
    <View style={[styles.row, !last && styles.divider]}>
      {leading}
      <View style={styles.text}>
        {typeof title === "string" ? <Text style={styles.title}>{title}</Text> : title}
        {subtitle ? <Text style={styles.subtitle}>{subtitle}</Text> : null}
      </View>
      {amount ? <Text style={[styles.amount, negative && styles.negative]}>{amount}</Text> : null}
    </View>
  );
}

export const rowText = StyleSheet.create({
  title: { fontFamily: fonts.sansSemi, fontSize: 15, color: colors.ink },
});

const styles = StyleSheet.create({
  row: { flexDirection: "row", alignItems: "center", gap: 12, paddingVertical: 9 },
  divider: { borderBottomWidth: 1, borderBottomColor: colors.line2 },
  text: { flex: 1 },
  title: rowText.title,
  subtitle: { fontFamily: fonts.sans, fontSize: 12.5, color: colors.muted, marginTop: 1 },
  amount: { fontFamily: fonts.sansSemi, fontSize: 15, color: colors.ink, fontVariant: ["tabular-nums"] },
  negative: { color: colors.rose },
});
