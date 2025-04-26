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
    
    /// Sound service for playing alerts
    private let soundService: SoundService
    
    /// Notification service for system notifications
    private let notificationService: NotificationService
    
    /// Statistics manager for tracking work sessions
    private let statisticsManager: StatisticsManager
    
    /// Timer for idle reminders
    private var idleReminderTimer: Timer?
    
    /// Set of cancellables for managing subscriptions
    private var cancellables = Set<AnyCancellable>()
    
    /// Initialize the state manager with required services
    /// - Parameters:
    ///   - timerService: The timer service to use
    ///   - soundService: The sound service to use
    ///   - notificationService: The notification service to use
    ///   - statisticsManager: The statistics manager to use
    init(timerService: TimerService = TimerService(),
         soundService: SoundService = SoundService(),
         notificationService: NotificationService = NotificationService(),
         statisticsManager: StatisticsManager = StatisticsManager()) {
        self.timerService = timerService
        self.soundService = soundService
        self.notificationService = notificationService
        self.statisticsManager = statisticsManager
        
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
        
        // Setup idle reminder timer
        setupIdleReminderTimer()
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
        
        // Start tracking the work session
        statisticsManager.startWorkSession()
        
        // Clear any idle reminders when starting work
        idleReminderTimer?.invalidate()
        notificationService.removePendingNotifications(ofType: .idleReminder)
    }
    
    /// Start a rest session
    private func startRest() {
        // Complete the work session tracking
        statisticsManager.completeWorkSession()
        
        // Play work complete sound and show notification
        soundService.playSound(type: .workComplete)
        notificationService.notifyWorkComplete()
        
        currentState = .rest
        timerService.start(duration: settings.restDurationSeconds)
    }
    
    /// Return to idle state
    private func startIdle() {
        // Play rest complete sound and show notification
        soundService.playSound(type: .restComplete)
        notificationService.notifyRestComplete()
        
        currentState = .idle
        timerService.pause()
        
        // Setup idle reminder timer when returning to idle
        setupIdleReminderTimer()
    }
    
    /// Handle timer completion based on current state
    private func handleTimerCompleted() {
        advance()
    }
    
    /// Setup the idle reminder timer
    private func setupIdleReminderTimer() {
        // Only set up if we're in idle state
        guard currentState == .idle else { return }
        
        // Cancel any existing timer
        idleReminderTimer?.invalidate()
        
        // Idle reminder interval (30 minutes = 1800 seconds)
        let reminderInterval: TimeInterval = 1800
        
        // Setup a new timer
        idleReminderTimer = Timer.scheduledTimer(withTimeInterval: reminderInterval, repeats: true) { [weak self] _ in
            self?.handleIdleReminderTick()
        }
    }
    
    /// Handle idle reminder timer tick
    private func handleIdleReminderTick() {
        // Only send reminders during active hours
        if isWithinActiveHours() && currentState == .idle {
            soundService.playSound(type: .reminder)
            notificationService.notifyIdleReminder(timeToNextReminder: 1800)
        }
    }
    
    /// Check if the current time is within active hours
    /// - Returns: True if within active hours, false otherwise
    private func isWithinActiveHours() -> Bool {
        let calendar = Calendar.current
        let now = Date()
        let hour = calendar.component(.hour, from: now)
        
        return hour >= settings.activeHoursStart && hour < settings.activeHoursEnd
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
    
    /// Access to today's statistics
    var todayStats: DailyStatistics? {
        statisticsManager.todayStats
    }
    
    /// Access to all statistics
    var allStats: [DailyStatistics] {
        statisticsManager.dailyStats
    }
    
    deinit {
        idleReminderTimer?.invalidate()
    }
} 
