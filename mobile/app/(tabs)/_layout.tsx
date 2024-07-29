import { Tabs } from "expo-router";
import { StyleSheet } from "react-native";
import { Icon, type IconName } from "@/components/Icon";
import { colors, fonts } from "@/constants/theme";

const TABS: { name: string; title: string; icon: IconName }[] = [
  { name: "index", title: "Home", icon: "grid" },
  { name: "budgets", title: "Budgets", icon: "pie" },
  { name: "bills", title: "Bills", icon: "repeat" },
  { name: "net-worth", title: "Net worth", icon: "trend" },
  { name: "household", title: "Household", icon: "users" },
];

export default function TabLayout() {
  return (
    <Tabs
      screenOptions={{
        headerShown: false,
        tabBarActiveTintColor: colors.violet,
        tabBarInactiveTintColor: colors.tabInactive,
        tabBarLabelStyle: { fontFamily: fonts.sansMedium, fontSize: 11 },
        tabBarStyle: styles.bar,
        sceneStyle: { backgroundColor: colors.bg },
      }}
    >
      {TABS.map((tab) => (
        <Tabs.Screen
          key={tab.name}
          name={tab.name}
          options={{
            title: tab.title,
            tabBarIcon: ({ color }: { color: string }) => <Icon name={tab.icon} color={color} size={23} />,
          }}
        />
      ))}
    </Tabs>
  );
}

const styles = StyleSheet.create({
  bar: {
    backgroundColor: "rgba(255,255,255,0.96)",
    borderTopColor: colors.line2,
    borderTopWidth: 1,
  },
});
