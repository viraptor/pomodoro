import SwiftUI

/// View for the menu bar dropdown
struct MenuBarView: View {
    /// Reference to the state manager
    @ObservedObject var stateManager: StateManager
    
    /// State to control showing the configuration window
    @State private var showingConfiguration = false
    
    var body: some View {
        VStack(spacing: 10) {
            // State indicator
            HStack {
                Image(systemName: stateManager.currentState == .idle ? "timer" :
                                stateManager.currentState == .work ? "timer.circle.fill" : "timer.circle")
                    .imageScale(.large)
                
                Text(stateManager.currentState.description)
                    .font(.headline)
                
                Spacer()
                
                if stateManager.currentState != .idle {
                    Text(stateManager.formattedRemainingTime)
                        .font(.system(.body, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 5)
            
            Divider()
            
            // Action button
            Button(action: {
                stateManager.advance()
            }) {
                Label(stateManager.currentState.actionText, systemImage: stateManager.currentState == .idle ? "play.fill" :
                            stateManager.currentState == .work ? "pause" : "stop.fill")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.borderedProminent)
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
} 
