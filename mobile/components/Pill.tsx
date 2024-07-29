import type { ReactNode } from "react";
import { Pressable, StyleSheet, Text } from "react-native";
import { colors, fonts } from "@/constants/theme";

export function Pill({ children, onPress, label }: { children: ReactNode; onPress?: () => void; label?: string }) {
  return (
    <Pressable style={styles.pill} onPress={onPress} accessibilityRole="button" accessibilityLabel={label}>
      {typeof children === "string" ? <Text style={styles.text}>{children}</Text> : children}
    </Pressable>
  );
}

const styles = StyleSheet.create({
  pill: {
    flexDirection: "row",
    alignItems: "center",
    gap: 4,
    height: 34,
    paddingHorizontal: 12,
    borderRadius: 999,
    backgroundColor: colors.paper,
    borderWidth: 1,
    borderColor: colors.line,
  },
  text: { fontFamily: fonts.sansSemi, fontSize: 13, color: colors.ink },
});
