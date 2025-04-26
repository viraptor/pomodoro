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
    
    /// State for tracking validation errors
    @State private var showValidationError = false
    @State private var validationErrorMessage = ""
    
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
                        .help("Duration of work sessions (1-60 minutes)")
                    
                    Stepper("Rest: \(restDuration) minutes", value: $restDuration, in: 1...30)
                        .help("Duration of rest sessions (1-30 minutes)")
                }
                
                Section(header: Text("Active Hours")) {
                    HStack {
                        Text("Start: ")
                        Picker("\(activeHoursStart):00", selection: $activeHoursStart) {
                            ForEach(0..<24) { hour in
                                Text("\(hour):00").tag(hour)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(width: 100)
                    }
                    .help("Start time for active hours (when reminders will be sent)")
                    
                    HStack {
                        Text("End: ")
                        Picker("\(activeHoursEnd):00", selection: $activeHoursEnd) {
                            ForEach(0..<24) { hour in
                                Text("\(hour):00").tag(hour)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(width: 100)
                    }
                    .help("End time for active hours (when reminders will be sent)")
                }
            }
            
            if showValidationError {
                Text(validationErrorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Spacer()
                
                Button("Save") {
                    if validateSettings() {
                        saveSettings()
                        dismiss()
                    }
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding()
        }
        .frame(width: 400, height: 450)
    }
    
    /// Validate the settings before saving
    private func validateSettings() -> Bool {
        // Validate work duration
        if workDuration < 1 || workDuration > 60 {
            showValidationError = true
            validationErrorMessage = "Work duration must be between 1 and 60 minutes."
            return false
        }
        
        // Validate rest duration
        if restDuration < 1 || restDuration > 30 {
            showValidationError = true
            validationErrorMessage = "Rest duration must be between 1 and 30 minutes."
            return false
        }
        
        // Validate active hours
        if activeHoursStart < 0 || activeHoursStart > 23 {
            showValidationError = true
            validationErrorMessage = "Start hour must be between 0 and 23."
            return false
        }
        
        if activeHoursEnd < 0 || activeHoursEnd > 23 {
            showValidationError = true
            validationErrorMessage = "End hour must be between 0 and 23."
            return false
        }
        
        // Validate active hours range makes sense
        if activeHoursStart >= activeHoursEnd {
            showValidationError = true
            validationErrorMessage = "Start hour must be before end hour."
            return false
        }
        
        showValidationError = false
        return true
    }
    
    /// Save the settings to the state manager
    private func saveSettings() {
        var newSettings = stateManager.settings
        newSettings.workDuration = workDuration
        newSettings.restDuration = restDuration
        newSettings.activeHoursStart = activeHoursStart
        newSettings.activeHoursEnd = activeHoursEnd
        
        stateManager.settings = newSettings
        stateManager.saveSettings()
    }
} 
