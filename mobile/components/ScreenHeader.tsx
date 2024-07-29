import type { ReactNode } from "react";
import { StyleSheet, Text, View } from "react-native";
import { colors, fonts } from "@/constants/theme";

export function ScreenHeader({ eyebrow, title, trailing }: { eyebrow: string; title: string; trailing?: ReactNode }) {
  return (
    <View style={styles.row}>
      <View style={styles.text}>
        <Text style={styles.eyebrow}>{eyebrow}</Text>
        <Text style={styles.title} accessibilityRole="header">
          {title}
        </Text>
      </View>
      {trailing}
    </View>
  );
}

const styles = StyleSheet.create({
  row: { flexDirection: "row", alignItems: "center", justifyContent: "space-between", marginTop: 4 },
  text: { flex: 1 },
  eyebrow: { fontFamily: fonts.sans, fontSize: 13, color: colors.muted },
  title: { fontFamily: fonts.serifSemi, fontSize: 26, letterSpacing: -0.5, color: colors.ink },
});
