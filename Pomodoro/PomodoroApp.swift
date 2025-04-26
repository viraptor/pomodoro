//
//  PomodoroApp.swift
//  Pomodoro
//
//  Created by Stan Pitucha on 26/4/2025.
//

import SwiftUI
import UserNotifications
import AppKit

// A shared coordinator object to pass state between App and AppDelegate
class AppCoordinator {
    static let shared = AppCoordinator()
    var stateManager: StateManager?
}

@main
struct PomodoroApp: App {
    /// The state manager that coordinates the application state
    @StateObject private var stateManager = StateManager()
    
    // Create an instance of AppDelegate to prevent app from closing when all windows are closed
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        // Ensure UNUserNotificationCenter delegate is set
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
        
        // Set up application termination observer
        setupTerminationObserver()
        
        // Store the stateManager in the shared coordinator for the AppDelegate to access
        AppCoordinator.shared.stateManager = stateManager
    }
    
    var body: some Scene {
        MenuBarExtra {
            MenuBarView(stateManager: stateManager)
        } label: {
            if stateManager.currentState != .idle {
                HStack(spacing: 2) {
                    Image(systemName: menuBarIcon)
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(stateColor)
                        .symbolEffect(.bounce, value: stateManager.isTimerRunning)
                    
                    Text(stateManager.formattedRemainingTime)
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .foregroundStyle(stateColor)
                }
            } else {
                Image(systemName: menuBarIcon)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(stateColor)
            }
        }
        .menuBarExtraStyle(.window)
    }
    
    /// Returns the appropriate icon for the current state
    private var menuBarIcon: String {
        switch stateManager.currentState {
        case .idle:
            return "timer"
        case .work:
            return "timer.circle.fill"
        case .rest:
            return "timer.circle"
        }
    }
    
    /// Returns the appropriate color for the current state
    private var stateColor: Color {
        switch stateManager.currentState {
        case .idle:
            return .secondary
        case .work:
            return .red
        case .rest:
            return .green
        }
    }
}

/// Delegate to handle notifications when the app is in the foreground
class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()
    
    /// Handle notifications when the app is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Allow banner and sound even when app is in foreground
        completionHandler([.banner, .sound])
    }
}

extension PomodoroApp {
    /// Set up observer for app termination to ensure statistics are saved
    private func setupTerminationObserver() {
        NotificationCenter.default.addObserver(
            forName: NSApplication.willTerminateNotification,
            object: nil,
            queue: .main) { _ in
                // Save any pending statistics data before shutdown
                self.saveStatisticsBeforeTermination()
            }
    }
    
    /// Ensure all statistics are properly saved before app exits
    private func saveStatisticsBeforeTermination() {
        // If in work state, complete the current session
        if stateManager.currentState == .work {
            // End current work session and save statistics
            stateManager.completeStatistics()
        }
    }
}
