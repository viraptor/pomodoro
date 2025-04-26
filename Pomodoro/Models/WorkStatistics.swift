import Foundation

/// Represents a completed work session
struct WorkSession: Codable, Equatable, Identifiable {
    /// Unique identifier for the session
    let id: UUID
    /// When the session started
    let startTime: Date
    /// When the session ended
    let endTime: Date
    /// Duration of the session in seconds
    var duration: TimeInterval {
        endTime.timeIntervalSince(startTime)
    }
    
    init(id: UUID = UUID(), startTime: Date, endTime: Date) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
    }
}

/// Aggregates statistics by date
struct DailyStatistics: Codable, Identifiable {
    /// Unique identifier (date string in YYYY-MM-DD format)
    var id: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    /// The date for these statistics
    let date: Date
    /// Work sessions completed on this date
    var sessions: [WorkSession]
    
    /// Total number of completed sessions
    var completedSessionsCount: Int {
        sessions.count
    }
    
    /// Total time spent in work sessions (in seconds)
    var totalWorkTime: TimeInterval {
        sessions.reduce(0) { $0 + $1.duration }
    }
    
    /// Formatted total work time (HH:MM)
    var formattedTotalWorkTime: String {
        let hours = Int(totalWorkTime) / 3600
        let minutes = (Int(totalWorkTime) % 3600) / 60
        return String(format: "%02d:%02d", hours, minutes)
    }
}

/// Manages all usage statistics for the application
class StatisticsManager: ObservableObject {
    /// Published collection of daily statistics
    @Published private(set) var dailyStats: [DailyStatistics] = []
    
    /// Current work session (if in progress)
    private var currentSession: (UUID, Date)?
    
    /// URL for statistics storage file
    private var statisticsFileURL: URL {
        let fileManager = FileManager.default
        let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appDirectory = appSupportURL.appendingPathComponent("Pomodoro")
        
        // Create the directory if it doesn't exist
        if !fileManager.fileExists(atPath: appDirectory.path) {
            try? fileManager.createDirectory(at: appDirectory, withIntermediateDirectories: true)
        }
        
        return appDirectory.appendingPathComponent("statistics.json")
    }
    
    /// Initialize and load saved statistics
    init() {
        loadStatistics()
    }
    
    /// Records the start of a work session
    func startWorkSession() {
        currentSession = (UUID(), Date())
    }
    
    /// Records the completion of a work session
    func completeWorkSession() {
        guard let (id, startTime) = currentSession else { return }
        
        let session = WorkSession(id: id, startTime: startTime, endTime: Date())
        addSession(session)
        currentSession = nil
        saveStatistics()
    }
    
    /// Adds a session to the appropriate daily statistics
    private func addSession(_ session: WorkSession) {
        let calendar = Calendar.current
        let sessionDay = calendar.startOfDay(for: session.startTime)
        
        if let index = dailyStats.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: sessionDay) }) {
            // Add to existing day
            dailyStats[index].sessions.append(session)
        } else {
            // Create new day
            let newDay = DailyStatistics(date: sessionDay, sessions: [session])
            dailyStats.append(newDay)
            // Sort by date (newest first)
            dailyStats.sort { $0.date > $1.date }
        }
    }
    
    /// Save statistics to disk
    func saveStatistics() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(dailyStats)
            try data.write(to: statisticsFileURL)
        } catch {
            print("Failed to save statistics: \(error)")
        }
    }
    
    /// Load statistics from disk
    func loadStatistics() {
        do {
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: statisticsFileURL.path) {
                let data = try Data(contentsOf: statisticsFileURL)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                dailyStats = try decoder.decode([DailyStatistics].self, from: data)
            }
        } catch {
            print("Failed to load statistics: \(error)")
            // Start with empty statistics if loading fails
            dailyStats = []
        }
    }
    
    /// Get statistics for today
    var todayStats: DailyStatistics? {
        let today = Calendar.current.startOfDay(for: Date())
        return dailyStats.first { Calendar.current.isDate($0.date, inSameDayAs: today) }
    }
    
    /// Reset all statistics (primarily for testing)
    func resetStatistics() {
        dailyStats = []
    }
    
    /// Set daily statistics (primarily for testing)
    func setDailyStats(_ stats: [DailyStatistics]) {
        dailyStats = stats
    }
} 
