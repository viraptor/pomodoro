import SwiftUI
import AppKit

/// View for the menu bar dropdown
struct MenuBarView: View {
    /// Reference to the state manager
    @ObservedObject var stateManager: StateManager
    
    /// State to control showing the configuration window
    @State private var showingConfiguration = false
    
    var body: some View {
        VStack(spacing: 10) {
            // State indicator and timer display
            VStack(spacing: 5) {
                HStack {
                    Image(systemName: stateManager.currentState == .idle ? "timer" :
                                    stateManager.currentState == .work ? "timer.circle.fill" : "timer.circle")
                        .imageScale(.large)
                        .foregroundStyle(stateColor)
                        // Conditionally apply the bounce effect only when timer is running
                        .if(stateManager.isTimerRunning) { view in
                            view.symbolEffect(.bounce.byLayer)
                        }
                    
                    Text(stateManager.currentState.description)
                        .font(.headline)
                        .foregroundStyle(stateColor)
                    
                    Spacer()
                    
                    if stateManager.currentState != .idle {
                        // Enhanced pulsing activity indicator with animation
                        if stateManager.isTimerRunning {
                            ZStack {
                                Circle()
                                    .fill(stateColor)
                                    .frame(width: 8, height: 8)
                                    .opacity(0.8)
                                
                                // Add ripple effect
                                ForEach(0..<3, id: \.self) { index in
                                    Circle()
                                        .stroke(stateColor, lineWidth: 1)
                                        .scaleEffect(stateManager.isTimerRunning ? 1.5 + CGFloat(index) * 0.3 : 1.0)
                                        .opacity(stateManager.isTimerRunning ? 0 : 1)
                                        .animation(
                                            .easeOut(duration: 1.5)
                                                .repeatForever(autoreverses: false)
                                                .delay(Double(index) * 0.3),
                                            value: stateManager.isTimerRunning
                                        )
                                }
                            }
                        } else {
                            Image(systemName: "pause.circle")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 5)
                
                // Enhanced timer display
                if stateManager.currentState != .idle {
                    VStack(spacing: 2) {
                        // Timer display with larger font
                        Text(stateManager.formattedRemainingTime)
                            .font(.system(.title, design: .monospaced))
                            .foregroundStyle(stateColor)
                            .fontWeight(.medium)
                            // Add visual alert when time is low
                            .opacity(stateManager.remainingTimePublished < 10 ? 0.6 + 0.4 * sin(Double(Date().timeIntervalSince1970) * 4) : 1.0)
                            .animation(.easeInOut(duration: 0.5), value: stateManager.remainingTimePublished < 10)
                        
                        // Enhanced progress bar with segments for better visual feedback
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // Background track
                                RoundedRectangle(cornerRadius: 2)
                                    .foregroundStyle(Color.secondary.opacity(0.2))
                                    .frame(width: geometry.size.width, height: 4)
                                
                                // Progress fill
                                RoundedRectangle(cornerRadius: 2)
                                    .foregroundStyle(stateColor)
                                    .frame(width: max(0, min(geometry.size.width * progressPercentage, geometry.size.width)), height: 4)
                                
                                // Segment markers (showing 25% increments)
                                HStack(spacing: 0) {
                                    ForEach(1..<4) { segment in
                                        Rectangle()
                                            .fill(Color.white.opacity(0.5))
                                            .frame(width: 1, height: 6)
                                            .offset(y: -1)
                                            .position(x: geometry.size.width * CGFloat(segment) / 4, y: 2)
                                    }
                                }
                                .frame(width: geometry.size.width)
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 2))
                        }
                        .frame(height: 4)
                        
                        // Show additional info about current session
                        Text(progressDescription)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .padding(.top, 2)
                    }
                    .padding(.horizontal, 5)
                }
            }
            .padding(.vertical, 5)
            
            Divider()
            
            // Action button
            Button(action: {
                stateManager.advance()
            }) {
                Label(stateManager.currentState.actionText, systemImage: 
                    stateManager.currentState == .idle ? "play.fill" :
                    stateManager.currentState == .work ? "pause" : "stop.fill")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.borderedProminent)
            .tint(stateColor)
            .controlSize(.large)
            .padding(.horizontal, 5)
            
            Divider()
            
            // Configuration button
            Button(action: {
                showingConfiguration = true
            }) {
                Label("Configuration", systemImage: "gear")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 5)
            
            Divider()
            
            // Today's Statistics Summary
            if let todayStats = stateManager.todayStats, todayStats.completedSessionsCount > 0 {
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        Image(systemName: "chart.bar.fill")
                            .foregroundStyle(.blue)
                        Text("Today's Progress")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 5)
                    
                    HStack(spacing: 10) {
                        Label("\(todayStats.completedSessionsCount)", systemImage: "checkmark.circle")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Label(todayStats.formattedTotalWorkTime, systemImage: "timer")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 5)
                    
                    Button(action: {
                        showingConfiguration = true
                    }) {
                        Text("View Details")
                            .font(.caption)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 5)
                    .padding(.top, 2)
                }
                .padding(.vertical, 5)
                
                Divider()
            }
            
            // Quit button
            Button(action: {
                NSApplication.shared.terminate(nil)
            }) {
                Label("Quit", systemImage: "power")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 5)
        }
        .padding(10)
        .frame(width: 250)
        .onChange(of: showingConfiguration) { newValue in
            if newValue {
                openConfigurationWindow()
                // Reset the state immediately after scheduling window opening
                showingConfiguration = false
            }
        }
    }
    
    /// Opens a standalone configuration window
    private func openConfigurationWindow() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 500),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Pomodoro Configuration"
        window.center()
        
        // Prevent window from releasing when closed, which would terminate the app
        window.isReleasedWhenClosed = false
        
        window.contentView = NSHostingView(rootView: 
            ConfigurationView(stateManager: stateManager)
        )
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    /// Progress percentage for the current timer session
    private var progressPercentage: Double {
        let total: Double
        if stateManager.currentState == .work {
            total = Double(stateManager.settings.workDurationSeconds)
        } else if stateManager.currentState == .rest {
            total = Double(stateManager.settings.restDurationSeconds)
        } else {
            return 0
        }
        
        let remaining = Double(stateManager.remainingTimePublished)
        return max(0, min(1, (total - remaining) / total))
    }
    
    /// Textual description of the progress
    private var progressDescription: String {
        let percentage = Int(progressPercentage * 100)
        if stateManager.currentState == .work {
            return "Focus session: \(percentage)% complete"
        } else if stateManager.currentState == .rest {
            return "Break time: \(percentage)% complete"
        } else {
            return ""
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

// Extension to add conditional modifier support
extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, content: (Self) -> Content) -> some View {
        if condition {
            content(self)
        } else {
            self
        }
    }
} 
