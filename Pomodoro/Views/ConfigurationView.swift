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
    
    /// Tab selection
    @State private var selectedTab = 0
    
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
            
            TabView(selection: $selectedTab) {
                settingsTab
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }
                    .tag(0)
                
                statisticsTab
                    .tabItem {
                        Label("Statistics", systemImage: "chart.bar")
                    }
                    .tag(1)
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
                .disabled(selectedTab != 0) // Only enable in settings tab
            }
            .padding()
        }
        .frame(width: 500, height: 500)
    }
    
    /// The settings tab
    var settingsTab: some View {
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
    }
    
    /// The statistics tab
    var statisticsTab: some View {
        VStack {
            if let todayStats = stateManager.todayStats {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Today's Progress")
                        .font(.headline)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Completed Sessions")
                                .font(.subheadline)
                            Text("\(todayStats.completedSessionsCount)")
                                .font(.title)
                                .foregroundColor(.blue)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .leading) {
                            Text("Total Work Time")
                                .font(.subheadline)
                            Text(todayStats.formattedTotalWorkTime)
                                .font(.title)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                .padding()
            } else {
                Text("No sessions completed today")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding()
            }
            
            Divider()
            
            VStack(alignment: .leading) {
                Text("Historical Data")
                    .font(.headline)
                    .padding(.horizontal)
                
                List {
                    ForEach(stateManager.allStats.prefix(7)) { dailyStat in
                        HStack {
                            Text(formatDate(dailyStat.date))
                            Spacer()
                            Text("\(dailyStat.completedSessionsCount) sessions")
                            Spacer()
                            Text(dailyStat.formattedTotalWorkTime)
                        }
                    }
                }
                .frame(height: 200)
                .listStyle(PlainListStyle())
            }
        }
    }
    
    /// Format date to show day and month
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, MMM d"
        return formatter.string(from: date)
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
