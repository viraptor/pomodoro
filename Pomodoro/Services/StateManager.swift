import Foundation
import Combine

/// Manages the overall state of the Pomodoro application
class StateManager: ObservableObject {
    /// Current state of the Pomodoro timer
    @Published private(set) var currentState: PomodoroState = .idle
    
    /// Current application settings
    @Published var settings: AppSettings = AppSettings.defaultSettings
    
    /// Indicates whether the timer is currently running
    @Published private(set) var isTimerRunning = false
    
    /// Remaining time in the current session (in seconds)
    var remainingTime: TimeInterval {
        timerService.remainingTime
    }
    
    /// Timer service that manages timing functionality
    private let timerService: TimerService
    
    /// Set of cancellables for managing subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    /// Initialize the state manager with a timer service
    /// - Parameter timerService: The timer service to use
    init(timerService: TimerService = TimerService()) {
        self.timerService = timerService
        
        // Subscribe to timer completion events
        timerService.timerCompletedPublisher
            .sink { [weak self] _ in
                self?.handleTimerCompleted()
            }
            .store(in: &cancellables)
        
        // Subscribe to timer running state changes
        timerService.$isRunning
            .sink { [weak self] isRunning in
                self?.isTimerRunning = isRunning
            }
            .store(in: &cancellables)
        
        // Load settings from UserDefaults
        loadSettings()
    }
    
    /// Advance to the next state in the Pomodoro cycle
    func advance() {
        switch currentState {
        case .idle:
            startWork()
        case .work:
            startRest()
        case .rest:
            startIdle()
        }
    }
    
    /// Start a work session
    private func startWork() {
        currentState = .work
        timerService.start(duration: settings.workDurationSeconds)
    }
    
    /// Start a rest session
    private func startRest() {
        currentState = .rest
        timerService.start(duration: settings.restDurationSeconds)
    }
    
    /// Return to idle state
    private func startIdle() {
        currentState = .idle
        timerService.pause()
    }
    
    /// Handle timer completion based on current state
    private func handleTimerCompleted() {
        advance()
    }
    
    /// Save current settings to UserDefaults
    func saveSettings() {
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: "AppSettings")
        }
    }
    
    /// Load settings from UserDefaults
    private func loadSettings() {
        if let data = UserDefaults.standard.data(forKey: "AppSettings"),
           let decoded = try? JSONDecoder().decode(AppSettings.self, from: data) {
            settings = decoded
        }
    }
    
    /// Return formatted remaining time string
    var formattedRemainingTime: String {
        let minutes = Int(timerService.remainingTime) / 60
        let seconds = Int(timerService.remainingTime) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
} 
