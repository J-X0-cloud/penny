import type { ReactNode } from "react";
import { Pressable, StyleSheet, Text, View } from "react-native";
import { colors, fonts } from "@/constants/theme";

interface SectionTitleProps {
  title: string;
  badge?: ReactNode;
  action?: { label: string; onPress: () => void };
}

export function SectionTitle({ title, badge, action }: SectionTitleProps) {
  return (
    <View style={styles.row}>
      <Text style={styles.title}>{title}</Text>
      {badge}
      {action ? (
        <Pressable onPress={action.onPress} hitSlop={8} style={styles.action}>
          <Text style={styles.actionText}>{action.label}</Text>
        </Pressable>
      ) : null}
    </View>
  );
}

export function CountBadge({ count }: { count: number }) {
  return <Text style={styles.badge}>{count}</Text>;
}

const styles = StyleSheet.create({
  row: { flexDirection: "row", alignItems: "center", gap: 6, marginTop: 6 },
  title: { fontFamily: fonts.sansSemi, fontSize: 15, color: colors.ink },
  action: { marginLeft: "auto" },
  actionText: { fontFamily: fonts.sansMedium, fontSize: 13.5, color: colors.violet },
  badge: {
    overflow: "hidden",
    minWidth: 20,
    textAlign: "center",
    fontFamily: fonts.sansSemi,
    fontSize: 11,
    color: "#FFFFFF",
    backgroundColor: colors.copper,
    borderRadius: 10,
    paddingHorizontal: 6,
    paddingVertical: 1,
  },
});
