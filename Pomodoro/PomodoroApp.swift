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
                Text(stateManager.formattedRemainingTime)
                    .font(.system(.body, design: .monospaced))
            } icon: {
                Image(systemName: stateManager.currentState == .idle ? "timer" :
                                stateManager.currentState == .work ? "timer.circle.fill" : "timer.circle")
            }
        }
        .menuBarExtraStyle(.window)
    }
}
