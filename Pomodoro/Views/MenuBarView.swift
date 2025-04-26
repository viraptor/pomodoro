import SwiftUI

/// View for the menu bar dropdown
struct MenuBarView: View {
    /// Reference to the state manager
    @ObservedObject var stateManager: StateManager
    
    /// State to control showing the configuration window
    @State private var showingConfiguration = false
    
    var body: some View {
        VStack {
            Button(stateManager.currentState.actionText) {
                stateManager.advance()
            }
            .buttonStyle(.borderedProminent)
            .padding(.vertical, 5)
            
            Divider()
            
            Button("Configuration") {
                showingConfiguration = true
            }
            .padding(.vertical, 5)
            
            Divider()
            
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .padding(.vertical, 5)
        }
        .padding(5)
        .frame(width: 200)
        .sheet(isPresented: $showingConfiguration) {
            ConfigurationView(stateManager: stateManager)
        }
    }
} 
