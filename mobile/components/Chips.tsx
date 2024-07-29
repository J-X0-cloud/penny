import { StyleSheet, View } from "react-native";
import { colors } from "@/constants/theme";
import { categoryByKey } from "@/lib/finance";
import type { CategoryKey } from "@/lib/types";
import { Icon, type IconName } from "./Icon";

interface ChipBoxProps {
  icon: IconName;
  fg: string;
  bg: string;
  small?: boolean;
}

function ChipBox({ icon, fg, bg, small }: ChipBoxProps) {
  return (
    <View style={[styles.chip, small && styles.small, { backgroundColor: bg }]}>
      <Icon name={icon} color={fg} size={small ? 15 : 19} />
    </View>
  );
}

export function CategoryChip({ category, small }: { category: CategoryKey; small?: boolean }) {
  const c = categoryByKey[category];
  return <ChipBox icon={c.icon} fg={c.fg} bg={c.bg} small={small} />;
}

export function IconChip({ icon, small }: { icon: IconName; small?: boolean }) {
  return <ChipBox icon={icon} fg={colors.violet} bg={colors.violetLight} small={small} />;
}

const styles = StyleSheet.create({
  chip: { width: 38, height: 38, borderRadius: 11, alignItems: "center", justifyContent: "center" },
  small: { width: 28, height: 28, borderRadius: 8 },
});
