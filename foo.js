Settings.setSettings({
  keyMappings:
    "map j scrollLeft\nmap k scrollDown\nmap l scrollUp\nmap ; scrollRight",
  settingsVersion: "2.1.2",
  exclusionRules: [
    {
      passKeys: "",
      pattern: "https?://mail.google.com/*",
    },
    {
      passKeys: "",
      pattern: "https?://godbolt.org/*",
    },
    {
      passKeys: "",
      pattern: "https?://www.youtube.com/*",
    },
    {
      passKeys: "",
      pattern: "https?://www.hackerrank.com/*",
    },
    {
      passKeys: "",
      pattern: "https?://leetcode.com/*",
    },
  ],
}).then(() => {
  OptionsPage.setFormFromSettings(Settings.getSettings());
});
