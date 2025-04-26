//
//  PomodoroApp.swift
//  Pomodoro
//
//  Created by Stan Pitucha on 26/4/2025.
//

import SwiftUI

@main
struct PomodoroApp: App {
    /// The state manager that coordinates the application state
    @StateObject private var stateManager = StateManager()
    
    var body: some Scene {
        MenuBarExtra {
            MenuBarView(stateManager: stateManager)
        } label: {
            Label {
                if stateManager.currentState != .idle {
                    Text(stateManager.formattedRemainingTime)
                        .font(.system(.body, design: .monospaced))
                        .help(stateManager.currentState.description)
                }
            } icon: {
                Image(systemName: menuBarIcon)
                    .symbolRenderingMode(.hierarchical)
                    .help("\(stateManager.currentState.description): \(stateManager.formattedRemainingTime)")
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
}
