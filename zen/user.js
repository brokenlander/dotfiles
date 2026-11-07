// === zen-sync managed block — deployed by scripts/zen-sync.sh, do not edit here ===
//
// This file opts Zen-specific prefs INTO Firefox Sync. It sets only "sync this
// pref" sentinels and engine switches — never pref *values*. The actual values
// (your accent color, toggles, etc.) travel through your Mozilla account, so do
// NOT pin values for these prefs anywhere, or the pin overrides what Sync sends.
//
// Sign every machine into the same Mozilla account and these follow you.

// --- Native engines: favorites / essentials / spaces / folders / pinned tabs ---
// (Zen Twilight-gates this by default; force it on for stable builds.)
user_pref("services.sync.engine.spaces", true);

// --- Appearance / theme ---
user_pref("services.sync.prefs.sync.zen.theme.accent-color", true);
user_pref("services.sync.prefs.sync.zen.theme.content-element-separation", true);
user_pref("services.sync.prefs.sync.zen.theme.dark-mode-bias", true);
user_pref("services.sync.prefs.sync.zen.theme.gradient.show-custom-colors", true);
user_pref("services.sync.prefs.sync.zen.theme.essentials-favicon-bg", true);
user_pref("services.sync.prefs.sync.zen.theme.use-system-colors", true);
user_pref("services.sync.prefs.sync.zen.theme.hide-tab-throbber", true);
user_pref("services.sync.prefs.sync.zen.theme.hide-unified-extensions-button", true);
user_pref("services.sync.prefs.sync.zen.theme.disable-lightweight", true);
user_pref("services.sync.prefs.sync.zen.theme.border-radius", true);

// --- Compact mode ---
user_pref("services.sync.prefs.sync.zen.view.compact.hide-tabbar", true);
user_pref("services.sync.prefs.sync.zen.view.compact.hide-toolbar", true);
user_pref("services.sync.prefs.sync.zen.view.compact.toolbar-flash-popup", true);
user_pref("services.sync.prefs.sync.zen.view.compact.toolbar-flash-popup.duration", true);
user_pref("services.sync.prefs.sync.zen.view.compact.toolbar-hide-after-hover.duration", true);
user_pref("services.sync.prefs.sync.zen.view.compact.sidebar-keep-hover.duration", true);
user_pref("services.sync.prefs.sync.zen.view.compact.outside-window-edge-offset.horizontal", true);
user_pref("services.sync.prefs.sync.zen.view.compact.outside-window-edge-offset.vertical", true);
user_pref("services.sync.prefs.sync.zen.view.compact.animate-sidebar", true);
user_pref("services.sync.prefs.sync.zen.view.compact.show-sidebar-and-toolbar-on-hover", true);
user_pref("services.sync.prefs.sync.zen.view.compact.show-background-tab-toast", true);

// --- Browser view ---
user_pref("services.sync.prefs.sync.zen.view.use-single-toolbar", true);
user_pref("services.sync.prefs.sync.zen.view.sidebar-expanded", true);
user_pref("services.sync.prefs.sync.zen.view.hide-window-controls", true);
user_pref("services.sync.prefs.sync.zen.view.window.scheme", true);
user_pref("services.sync.prefs.sync.zen.view.shift-down-site-on-hover", true);
user_pref("services.sync.prefs.sync.zen.view.draggable-sidebar", true);
user_pref("services.sync.prefs.sync.zen.view.borderless-fullscreen", true);
user_pref("services.sync.prefs.sync.zen.view.drag-window-from-content.height-percentage", true);
user_pref("services.sync.prefs.sync.zen.view.overflow-webext-toolbar", true);
user_pref("services.sync.prefs.sync.zen.view.overflow-webext-toolbar-threshold", true);

// --- Tabs / behavior ---
user_pref("services.sync.prefs.sync.zen.tabs.vertical", true);
user_pref("services.sync.prefs.sync.zen.tabs.vertical.right-side", true);
user_pref("services.sync.prefs.sync.zen.tabs.rename-tabs", true);
user_pref("services.sync.prefs.sync.zen.tabs.essentials.max", true);
user_pref("services.sync.prefs.sync.zen.tabs.close-window-with-empty", true);
user_pref("services.sync.prefs.sync.zen.tabs.select-recently-used-on-close", true);
user_pref("services.sync.prefs.sync.zen.tabs.open-pinned-in-new-tab", true);
user_pref("services.sync.prefs.sync.zen.tabs.folder-dragover-threshold-percent", true);
user_pref("services.sync.prefs.sync.zen.tabs.dnd-switch-space-delay", true);
user_pref("services.sync.prefs.sync.zen.startup.smooth-scroll-in-tabs", true);

// --- Media ---
user_pref("services.sync.prefs.sync.zen.mediacontrols.enabled", true);

// --- Toolbar widget layout (which buttons sit where). Syncs, but can be finicky
//     across different window sizes — comment out if it causes layout churn. ---
user_pref("services.sync.prefs.sync.browser.uiCustomization.state", true);

// === end zen-sync managed block ===
