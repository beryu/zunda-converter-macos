import AppKit
import Combine
import SwiftUI

final class StatusBarController {
    private var statusItem: NSStatusItem?
    private var cancellable: AnyCancellable?

    init() {
        setupStatusBar()
        
        // Rebuild menu when conversion mode changes so checkmarks update.
        // .dropFirst() skips the initial value (already handled by setupStatusBar).
        // .receive(on:) ensures menu updates happen on the next run loop tick.
        cancellable = SettingsStore.shared.$conversionMode
            .dropFirst()
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.rebuildMenu()
            }
    }

    private func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        guard let button = statusItem?.button else { return }
        button.image = NSImage(systemSymbolName: "bubble.left.fill", accessibilityDescription: "ZundaConverter")
        button.image?.size = NSSize(width: 18, height: 18)

        rebuildMenu()
    }

    private func rebuildMenu() {
        let menu = NSMenu()

        // === Conversion mode submenu ===
        let modeItem = NSMenuItem(title: "変換モード", action: nil, keyEquivalent: "")
        let modeSubmenu = NSMenu()

        for mode in ConversionMode.allCases {
            let item = NSMenuItem(
                title: mode.displayName,
                action: #selector(selectMode(_:)),
                keyEquivalent: ""
            )
            item.target = self
            item.representedObject = mode.rawValue
            item.state = (SettingsStore.shared.conversionMode == mode) ? .on : .off
            
            // Show warning icon if AI mode is not available
            if mode == .ai {
                if #available(macOS 26, *) {
                    if !LLMConverter.shared.isAvailable {
                        item.title = "\(mode.displayName) ⚠️"
                    }
                } else {
                    item.title = "\(mode.displayName) ⚠️"
                }
            }
            
            modeSubmenu.addItem(item)
        }

        modeItem.submenu = modeSubmenu
        menu.addItem(modeItem)

        menu.addItem(NSMenuItem.separator())

        // === Settings ===
        let settingsItem = NSMenuItem(
            title: "設定...",
            action: #selector(openSettings),
            keyEquivalent: ","
        )
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(NSMenuItem.separator())

        // === Quit ===
        let quitItem = NSMenuItem(
            title: "ZundaConverter を終了",
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        )
        menu.addItem(quitItem)

        statusItem?.menu = menu
    }

    @objc private func selectMode(_ sender: NSMenuItem) {
        guard let rawValue = sender.representedObject as? String,
              let mode = ConversionMode(rawValue: rawValue) else { return }
        SettingsStore.shared.conversionMode = mode
    }

    @objc private func openSettings() {
        SettingsWindowController.shared.showSettings()
    }
}
