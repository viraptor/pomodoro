import Foundation

/// Represents the current state of the Pomodoro timer
enum PomodoroState: String, Codable {
    case idle
    case work
    case rest
    
    /// Returns the next state in the Pomodoro cycle
    func next() -> PomodoroState {
        switch self {
        case .idle:
            return .work
        case .work:
            return .rest
        case .rest:
            return .idle
        }
    }
    
    /// Returns a user-friendly description of the current state
    var description: String {
        switch self {
        case .idle: return "Idle"
        case .work: return "Working"
        case .rest: return "Resting"
        }
    }
    
    /// Returns the action text for advancing to the next state
    var actionText: String {
        switch self {
        case .idle: return "Start Work"
        case .work: return "Take a Break"
        case .rest: return "End Break"
        }
    }
} 
