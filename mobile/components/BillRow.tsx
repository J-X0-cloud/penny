import { StyleSheet, Text } from "react-native";
import { colors, fonts } from "@/constants/theme";
import { formatMoney } from "@/lib/money";
import type { Bill } from "@/lib/types";
import { IconChip } from "./Chips";
import { Row, rowText } from "./Row";

export function BillRow({ bill, last }: { bill: Bill; last?: boolean }) {
  return (
    <Row
      last={last}
      leading={<IconChip icon={bill.icon} />}
      title={
        <Text style={rowText.title}>
          {bill.name}
          {bill.priceChange ? <Text style={styles.up}>  +{formatMoney(bill.priceChange)}</Text> : null}
        </Text>
      }
      subtitle={bill.priceChange ? bill.due : `${bill.due} · ${bill.note}`}
      amount={formatMoney(bill.amount)}
    />
  );
}

const styles = StyleSheet.create({
  up: { fontFamily: fonts.sansSemi, fontSize: 12, color: colors.rose },
});
