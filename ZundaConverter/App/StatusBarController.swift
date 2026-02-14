import AppKit
import SwiftUI

final class StatusBarController {
    private var statusItem: NSStatusItem?

    init() {
        setupStatusBar()
    }

    private func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        guard let button = statusItem?.button else { return }
        button.image = NSImage(systemSymbolName: "bubble.left.fill", accessibilityDescription: "ZundaConverter")
        button.image?.size = NSSize(width: 18, height: 18)

        let menu = NSMenu()

        // Conversion mode
        let modeItem = NSMenuItem(title: "変換モード", action: nil, keyEquivalent: "")
        let modeSubmenu = NSMenu()

        let ruleBasedItem = NSMenuItem(
            title: "ルールベース（高速）",
            action: #selector(selectRuleBasedMode),
            keyEquivalent: ""
        )
        ruleBasedItem.target = self
        ruleBasedItem.state = SettingsStore.shared.conversionMode == .ruleBased ? .on : .off
        modeSubmenu.addItem(ruleBasedItem)

        modeItem.submenu = modeSubmenu
        menu.addItem(modeItem)

        menu.addItem(NSMenuItem.separator())

        // Settings
        let settingsItem = NSMenuItem(
            title: "設定...",
            action: #selector(openSettings),
            keyEquivalent: ","
        )
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(NSMenuItem.separator())

        // Quit
        let quitItem = NSMenuItem(
            title: "ZundaConverter を終了",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        )
        menu.addItem(quitItem)

        statusItem?.menu = menu
    }

    @objc private func selectRuleBasedMode() {
        SettingsStore.shared.conversionMode = .ruleBased
    }

    @objc private func openSettings() {
        NSApp.activate(ignoringOtherApps: true)
        // Open the Settings window (SwiftUI Settings scene)
        if #available(macOS 14.0, *) {
            NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        } else {
            NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
        }
    }
}
