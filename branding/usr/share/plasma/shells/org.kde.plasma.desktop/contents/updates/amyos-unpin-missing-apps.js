// Plasma pins apps a minimal Amy OS doesn't install, like Discover, and shows
// them as blank icons. Unpin every launcher whose app isn't there.

// A new panel hasn't saved its pins yet when this runs, so start from Plasma's.
const plasmaLaunchers = [
  "applications:systemsettings.desktop",
  "applications:org.kde.discover.desktop",
  "preferred://filemanager",
  "preferred://browser",
];

function installed(launcher) {
  if (launcher.startsWith("applications:")) {
    return applicationExists(launcher.slice("applications:".length));
  }
  if (launcher.startsWith("preferred://")) {
    return defaultApplication(launcher.slice("preferred://".length), true) !== "";
  }
  return true;
}

for (const panel of panels()) {
  for (const widget of panel.widgets()) {
    if (widget.type !== "org.kde.plasma.icontasks" && widget.type !== "org.kde.plasma.taskmanager") {
      continue;
    }
    widget.currentConfigGroup = ["General"];
    const saved = String(widget.readConfig("launchers", "")).split(",").filter(Boolean);
    const launchers = saved.length ? saved : plasmaLaunchers;
    const kept = launchers.filter(installed);
    if (kept.length !== saved.length) {
      widget.writeConfig("launchers", kept);
    }
  }
}
