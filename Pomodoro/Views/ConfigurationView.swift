import SwiftUI
import AppKit

/// View for configuring Pomodoro app settings
struct ConfigurationView: View {
    /// Reference to the state manager
    @ObservedObject var stateManager: StateManager
    
    /// Environment variable to dismiss the view (used when in sheet presentation)
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
            
            // Note about how to close the window
            Text("Click Save or Cancel to close this window")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            HStack {
                Button("Cancel") {
                    closeWindow()
                }
                .keyboardShortcut(.cancelAction)
                
                Spacer()
                
                Button("Save") {
                    if validateSettings() {
                        saveSettings()
                        closeWindow()
                    }
                }
                .keyboardShortcut(.defaultAction)
                .disabled(selectedTab != 0) // Only enable in settings tab
            }
            .padding()
        }
        .frame(width: 500, height: 500)
    }
    
    /// Close the current window
    private func closeWindow() {
        // Try to find the window and close it
        if let window = NSApplication.shared.windows.first(where: { ($0.contentView as? NSHostingView<ConfigurationView>) != nil }) {
            window.close()
        } else {
            // Fall back to dismiss environment if not found
            dismiss()
        }
    }
    
    /// The settings tab
    var settingsTab: some View {
        Form {
            Section(header: Text("Session Duration")) {
                HStack {
                    Text("Work:")
                    TextField("", value: $workDuration, formatter: NumberFormatter())
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 50)
                    Text("minutes")
                    Stepper("", value: $workDuration, in: 1...60)
                        .labelsHidden()
                }
                .help("Duration of work sessions (1-60 minutes)")
                
                HStack {
                    Text("Rest:")
                    TextField("", value: $restDuration, formatter: NumberFormatter())
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 50)
                    Text("minutes")
                    Stepper("", value: $restDuration, in: 1...30)
                        .labelsHidden()
                }
                .help("Duration of rest sessions (1-30 minutes)")
            }
            
            Section(header: Text("Active Hours")) {
                HStack {
                    Text("Start: ")
                    Picker("", selection: $activeHoursStart) {
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
                    Picker("", selection: $activeHoursEnd) {
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
                    
                    // Add visualization of today's work sessions
                    if !todayStats.sessions.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Today's Sessions")
                                .font(.subheadline)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(todayStats.sessions) { session in
                                        SessionView(session: session)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                            .frame(height: 70)
                        }
                        .padding(.top, 8)
                    }
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
                
                // Enhanced historical statistics view
                if !stateManager.allStats.isEmpty {
                    VStack(spacing: 12) {
                        // Weekly summary chart
                        WeeklyStatsView(stats: stateManager.allStats.prefix(7))
                            .frame(height: 160)
                            .padding(.horizontal)
                        
                        Divider()
                        
                        // Daily breakdown list
                        List {
                            ForEach(stateManager.allStats.prefix(7)) { dailyStat in
                                HStack {
                                    Text(formatDate(dailyStat.date))
                                        .fontWeight(.medium)
                                    Spacer()
                                    Text("\(dailyStat.completedSessionsCount) sessions")
                                    Spacer()
                                    Text(dailyStat.formattedTotalWorkTime)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .listStyle(PlainListStyle())
                    }
                } else {
                    Text("No historical data available yet")
                        .foregroundColor(.secondary)
                        .padding()
                }
            }
        }
    }
    
    /// Visual representation of a single work session
    struct SessionView: View {
        let session: WorkSession
        
        var body: some View {
            VStack(alignment: .leading, spacing: 4) {
                // Session duration
                Text(formattedDuration(session.duration))
                    .font(.system(.caption, design: .monospaced))
                    .fontWeight(.medium)
                
                // Time visualization
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.red.opacity(0.2))
                        .frame(width: 60, height: 10)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.red)
                        .frame(width: min(60, 60 * min(session.duration / 3600, 1)), height: 10)
                }
                
                // Start time
                Text(formatTime(session.startTime))
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 6)
            .padding(.horizontal, 8)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(6)
        }
        
        private func formatTime(_ date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            return formatter.string(from: date)
        }
        
        private func formattedDuration(_ duration: TimeInterval) -> String {
            let minutes = Int(duration) / 60
            return "\(minutes) min"
        }
    }
    
    /// Weekly statistics visualization
    struct WeeklyStatsView: View {
        let stats: Array<DailyStatistics>.SubSequence
        
        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text("Weekly Focus Time")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(Array(stats.enumerated()), id: \.element.id) { index, stat in
                        VStack {
                            // Bar height based on work time (max 8 hours = 28800 seconds)
                            let height = CGFloat(stat.totalWorkTime / 28800.0 * 100)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.blue.opacity(0.7))
                                .frame(height: max(4, height))
                            
                            Text(formatShortDate(stat.date))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(.top, 10)
                
                Text("7-day total: \(formatTotalTime(totalWeeklyTime))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
        }
        
        private var totalWeeklyTime: TimeInterval {
            stats.reduce(0) { $0 + $1.totalWorkTime }
        }
        
        private func formatShortDate(_ date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "E"
            return formatter.string(from: date)
        }
        
        private func formatTotalTime(_ time: TimeInterval) -> String {
            let hours = Int(time) / 3600
            let minutes = (Int(time) % 3600) / 60
            return "\(hours)h \(minutes)m"
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
        // Clear any previous validation errors
        showValidationError = false
        
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
