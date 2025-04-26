import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    // This prevents the app from terminating when all windows are closed
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
    
    // This enables secure state restoration
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    // This is called when the app is reopened via Dock or other means
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        // If there are no visible windows, we should show our configuration window
        if !flag {
            // Only attempt to open the configuration window if we have a state manager
            if let stateManager = AppCoordinator.shared.stateManager {
                DispatchQueue.main.async {
                    self.openConfigurationWindow(stateManager: stateManager)
                }
            }
        }
        return true
    }
    
    // Opens a configuration window with the provided state manager
    private func openConfigurationWindow(stateManager: StateManager) {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 500),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Pomodoro Configuration"
        window.center()
        window.isReleasedWhenClosed = false
        window.contentView = NSHostingView(rootView: 
            ConfigurationView(stateManager: stateManager)
        )
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
} 
