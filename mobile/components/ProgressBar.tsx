import { StyleSheet, View } from "react-native";
import { colors } from "@/constants/theme";

export function ProgressBar({ fraction, color }: { fraction: number; color: string }) {
  const pct = Math.round(Math.min(Math.max(fraction, 0), 1) * 100);
  return (
    <View style={styles.track} accessibilityRole="progressbar" accessibilityValue={{ min: 0, max: 100, now: pct }}>
      <View style={[styles.fill, { width: `${pct}%`, backgroundColor: color }]} />
    </View>
  );
}

const styles = StyleSheet.create({
  track: { height: 7, borderRadius: 4, backgroundColor: colors.barTrack, overflow: "hidden", marginVertical: 5 },
  fill: { height: "100%", borderRadius: 4 },
});
