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
                    HStack(spacing: 4) {
                        Circle()
                            .fill(stateColor)
                            .frame(width: 8, height: 8)
                            .opacity(stateManager.isTimerRunning ? 1.0 : 0.5)
                            .animation(.easeInOut(duration: 1.0).repeatForever(), value: stateManager.isTimerRunning)
                        
                        Text(stateManager.formattedRemainingTime)
                            .font(.system(.body, design: .monospaced))
                            .foregroundStyle(stateColor)
                            .help(stateManager.currentState.description)
                    }
                }
            } icon: {
                Image(systemName: menuBarIcon)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(stateColor)
                    .symbolEffect(.pulse, options: .repeating, value: stateManager.isTimerRunning && stateManager.remainingTime < 60)
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
