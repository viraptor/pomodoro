import SwiftUI

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
                    
                    Text(stateManager.currentState.description)
                        .font(.headline)
                        .foregroundStyle(stateColor)
                    
                    Spacer()
                    
                    if stateManager.currentState != .idle {
                        // Pulsing activity indicator
                        if stateManager.isTimerRunning {
                            Circle()
                                .fill(stateColor)
                                .frame(width: 8, height: 8)
                                .opacity(0.8)
                                .overlay {
                                    Circle()
                                        .stroke(stateColor, lineWidth: 1)
                                        .scaleEffect(stateManager.isTimerRunning ? 1.5 : 1.0)
                                        .opacity(stateManager.isTimerRunning ? 0 : 1)
                                        .animation(.easeOut(duration: 1.0).repeatForever(autoreverses: false), value: stateManager.isTimerRunning)
                                }
                        } else {
                            Image(systemName: "pause.circle")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 5)
                
                // Timer display
                if stateManager.currentState != .idle {
                    VStack(spacing: 2) {
                        Text(stateManager.formattedRemainingTime)
                            .font(.system(.title, design: .monospaced))
                            .foregroundStyle(stateColor)
                            .fontWeight(.medium)
                        
                        // Progress bar
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .foregroundStyle(Color.secondary.opacity(0.2))
                                    .frame(width: geometry.size.width, height: 4)
                                
                                Rectangle()
                                    .foregroundStyle(stateColor)
                                    .frame(width: max(0, min(geometry.size.width * progressPercentage, geometry.size.width)), height: 4)
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 2))
                        }
                        .frame(height: 4)
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
        .sheet(isPresented: $showingConfiguration) {
            ConfigurationView(stateManager: stateManager)
        }
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
        
        let remaining = Double(stateManager.remainingTime)
        return max(0, min(1, (total - remaining) / total))
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
