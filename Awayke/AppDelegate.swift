//
//  AppDelegate.swift
//  Awayke
//

import AppKit
import ServiceManagement

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private let powerManager = PowerManager()
    private let helper = HelperManager.shared

    private var isActive: Bool = false {
        didSet { refreshStatusItem() }
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        helper.register()

        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem = item

        if let button = item.button {
            button.target = self
            button.action = #selector(handleClick(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        refreshStatusItem()
    }

    func applicationWillTerminate(_ notification: Notification) {
        // Safety net: never leave the system with sleep disabled.
        if isActive {
            powerManager.disableSleep(false) { _ in }
        }
    }

    @objc private func handleClick(_ sender: NSStatusBarButton) {
        if NSApp.currentEvent?.type == .rightMouseUp {
            showMenu()
        } else {
            toggle()
        }
    }

    private func toggle() {
        let target = !isActive
        powerManager.disableSleep(target) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else { return }
                switch result {
                case .success: self.isActive = target
                case .failure(let error): self.presentError(error)
                }
            }
        }
    }

    private func showMenu() {
        let menu = NSMenu()

        let stateItem = NSMenuItem(title: isActive ? "Awayke: Active" : "Awayke: Inactive", action: nil, keyEquivalent: "")
        stateItem.isEnabled = false
        menu.addItem(stateItem)

        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: isActive ? "Turn Off" : "Turn On", action: #selector(menuToggle), keyEquivalent: ""))

        if let helperRow = helperStatusMenuItem() {
            menu.addItem(.separator())
            menu.addItem(helperRow)
        }

        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit Awayke", action: #selector(menuQuit), keyEquivalent: "q"))

        for item in menu.items where item.action != nil {
            item.target = self
        }
        statusItem?.menu = menu
        statusItem?.button?.performClick(nil)
        statusItem?.menu = nil
    }

    private func helperStatusMenuItem() -> NSMenuItem? {
        switch helper.state {
        case .enabled:
            return nil
        case .awaitingApproval:
            return NSMenuItem(title: "Approve helper in System Settings…", action: #selector(menuApproveHelper), keyEquivalent: "")
        case .notRegistered:
            let item = NSMenuItem(title: "Installing helper…", action: nil, keyEquivalent: "")
            item.isEnabled = false
            return item
        case .notFound:
            let item = NSMenuItem(title: "Helper not found (using fallback)", action: nil, keyEquivalent: "")
            item.isEnabled = false
            return item
        case .registrationFailed(let detail):
            let item = NSMenuItem(title: "Helper failed: \(detail)", action: nil, keyEquivalent: "")
            item.isEnabled = false
            return item
        }
    }

    @objc private func menuToggle() { toggle() }
    @objc private func menuApproveHelper() { helper.revealInSystemSettings() }
    @objc private func menuQuit() { NSApp.terminate(nil) }

    private func refreshStatusItem() {
        guard let button = statusItem?.button else { return }
        guard let base = NSImage(named: "StatusIcon") else { return }

        if isActive {
            button.image = orangeTinted(base)
        } else {
            base.isTemplate = true
            button.image = base
        }
        button.contentTintColor = nil
        button.title = ""
        button.toolTip = isActive ? "Awayke is on!" : "Awayke is off. Click to turn it on."
    }

    private func orangeTinted(_ source: NSImage) -> NSImage {
        let image = source.copy() as! NSImage
        image.isTemplate = false
        image.lockFocus()
        NSColor(red: 1, green: 0.6, blue: 0.1, alpha: 1).set()
        NSRect(origin: .zero, size: image.size).fill(using: .sourceAtop)
        image.unlockFocus()
        return image
    }

    private func presentError(_ error: Error) {
        let alert = NSAlert()
        alert.messageText = "Awayke couldn't toggle sleep."
        alert.informativeText = error.localizedDescription
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}
