import { StyleSheet, Text, View } from "react-native";
import Svg, { Circle, Defs, LinearGradient, Stop } from "react-native-svg";
import { fonts, members } from "@/constants/theme";
import type { Member } from "@/lib/types";

export function Avatar({ who, size = 34 }: { who: Member; size?: number }) {
  const [from, to] = members[who].gradient;
  const id = `av-${who}`;
  return (
    <View style={{ width: size, height: size }} accessibilityLabel={members[who].name}>
      <Svg width={size} height={size} style={StyleSheet.absoluteFill}>
        <Defs>
          <LinearGradient id={id} x1="0" y1="0" x2="1" y2="1">
            <Stop offset="0" stopColor={from} />
            <Stop offset="1" stopColor={to} />
          </LinearGradient>
        </Defs>
        <Circle cx={size / 2} cy={size / 2} r={size / 2} fill={`url(#${id})`} />
      </Svg>
      <View style={styles.center}>
        <Text style={[styles.initial, { fontSize: size * 0.4 }]}>{who}</Text>
      </View>
    </View>
  );
}

export function CoupleAvatars() {
  return (
    <View style={styles.pair}>
      <Avatar who="M" />
      <View style={styles.overlap}>
        <Avatar who="J" />
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  center: { ...StyleSheet.absoluteFillObject, alignItems: "center", justifyContent: "center" },
  initial: { fontFamily: fonts.sansSemi, color: "#FFFFFF" },
  pair: { flexDirection: "row" },
  overlap: { marginLeft: -8, borderRadius: 999, borderWidth: 2, borderColor: "#FBFAF8" },
});
