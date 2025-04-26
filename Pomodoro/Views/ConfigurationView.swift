import SwiftUI

/// View for configuring Pomodoro app settings
struct ConfigurationView: View {
    /// Reference to the state manager
    @ObservedObject var stateManager: StateManager
    
    /// Environment variable to dismiss the view
    @Environment(\.dismiss) private var dismiss
    
    /// Local copy of settings for editing
    @State private var workDuration: Int
    @State private var restDuration: Int
    @State private var activeHoursStart: Int
    @State private var activeHoursEnd: Int
    
    init(stateManager: StateManager) {
        self.stateManager = stateManager
        _workDuration = State(initialValue: stateManager.settings.workDuration)
        _restDuration = State(initialValue: stateManager.settings.restDuration)
        _activeHoursStart = State(initialValue: stateManager.settings.activeHoursStart)
        _activeHoursEnd = State(initialValue: stateManager.settings.activeHoursEnd)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Pomodoro Configuration")
                .font(.title)
                .padding(.top)
            
            Form {
                Section(header: Text("Session Duration")) {
                    Stepper("Work: \(workDuration) minutes", value: $workDuration, in: 1...60)
                    Stepper("Rest: \(restDuration) minutes", value: $restDuration, in: 1...30)
                }
                
                Section(header: Text("Active Hours")) {
                    Stepper("Start: \(activeHoursStart):00", value: $activeHoursStart, in: 0...23)
                    Stepper("End: \(activeHoursEnd):00", value: $activeHoursEnd, in: 0...23)
                }
            }
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Spacer()
                
                Button("Save") {
                    saveSettings()
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding()
        }
        .frame(width: 400, height: 400)
    }
    
    /// Save the settings to the state manager
    private func saveSettings() {
        var newSettings = stateManager.settings
        newSettings.workDuration = workDuration
        newSettings.restDuration = restDuration
        newSettings.activeHoursStart = activeHoursStart
        newSettings.activeHoursEnd = activeHoursEnd
        
        if newSettings.isValid() {
            stateManager.settings = newSettings
            stateManager.saveSettings()
        }
    }
} 
