/** Penny tokens, matching the web stylesheet so the phone and the site read as one product. */
export const colors = {
  bg: "#FBFAF8",
  paper: "#FFFFFF",
  ink: "#1B1633",
  ink2: "#4A4560",
  muted: "#7C7791",
  line: "#E8E3DB",
  line2: "#EFEBF4",
  violet: "#5B3FD9",
  violetDark: "#3F2AA6",
  violetLight: "#EEE9FD",
  lavender: "#B9A8FF",
  copper: "#C8743C",
  copperLight: "#F7E3D2",
  green: "#1C9B74",
  greenLight: "#DDF3EA",
  rose: "#D4485B",
  roseLight: "#FBE3E6",
  track: "#ECE8F6",
  barTrack: "#EFEBF4",
  tabInactive: "#A19CB3",
  heroTop: "#6A4FE6",
  heroBottom: "#3A2399",
  heroAccent: "#FFD9B8",
} as const;

export const fonts = {
  serif: "Fraunces_500Medium",
  serifSemi: "Fraunces_600SemiBold",
  sans: "Inter_400Regular",
  sansMedium: "Inter_500Medium",
  sansSemi: "Inter_600SemiBold",
} as const;

export const radius = { sm: 10, md: 16, lg: 20, pill: 999 } as const;

export const spacing = { xs: 4, sm: 8, md: 12, lg: 16, xl: 24 } as const;

export const members = {
  M: { name: "Maya", gradient: ["#8C74F0", "#5B3FD9"] },
  J: { name: "Jordan", gradient: ["#E39A5F", "#B25F2B"] },
} as const;
