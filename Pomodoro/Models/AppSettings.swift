import Foundation

/// Stores user configuration for the Pomodoro timer
struct AppSettings: Codable {
    /// Duration of work sessions in minutes
    var workDuration: Int
    
    /// Duration of rest sessions in minutes
    var restDuration: Int
    
    /// Start of active hours (hour of day, 0-23)
    var activeHoursStart: Int
    
    /// End of active hours (hour of day, 0-23)
    var activeHoursEnd: Int
    
    /// Default settings
    static let defaultSettings = AppSettings(
        workDuration: 25,
        restDuration: 5,
        activeHoursStart: 9,
        activeHoursEnd: 17
    )
    
    /// Validate that the settings are within acceptable ranges
    func isValid() -> Bool {
        return workDuration > 0 && workDuration <= 60 &&
               restDuration > 0 && restDuration <= 30 &&
               activeHoursStart >= 0 && activeHoursStart <= 23 &&
               activeHoursEnd >= 0 && activeHoursEnd <= 23
    }
    
    /// Returns the work duration in seconds
    var workDurationSeconds: TimeInterval {
        return TimeInterval(workDuration * 60)
    }
    
    /// Returns the rest duration in seconds
    var restDurationSeconds: TimeInterval {
        return TimeInterval(restDuration * 60)
    }
} 
