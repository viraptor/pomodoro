import Foundation
import Combine

/// Service that manages timer functionality for the Pomodoro app
class TimerService: ObservableObject {
    /// Current state of the timer
    @Published private(set) var isRunning = false
    
    /// Remaining time in the current session (in seconds)
    @Published private(set) var remainingTime: TimeInterval = 0
    
    /// Publisher that fires when timer completes
    var timerCompletedPublisher: AnyPublisher<Void, Never> {
        timerCompletedSubject.eraseToAnyPublisher()
    }
    
    /// Publisher that fires on each timer tick
    var timerTickPublisher: AnyPublisher<TimeInterval, Never> {
        $remainingTime.eraseToAnyPublisher()
    }
    
    private var timer: Timer?
    private let timerCompletedSubject = PassthroughSubject<Void, Never>()
    private var duration: TimeInterval = 0
    
    /// Start a new timer with the specified duration
    /// - Parameter duration: Duration of the timer in seconds
    func start(duration: TimeInterval) {
        self.duration = duration
        self.remainingTime = duration
        startTimer()
    }
    
    /// Pause the current timer
    func pause() {
        timer?.invalidate()
        timer = nil
        isRunning = false
    }
    
    /// Resume a paused timer
    func resume() {
        if !isRunning && remainingTime > 0 {
            startTimer()
        }
    }
    
    /// Reset the timer to its initial state
    func reset() {
        pause()
        remainingTime = duration
    }
    
    private func startTimer() {
        timer?.invalidate()
        isRunning = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.remainingTime > 0 {
                self.remainingTime -= 1
            } else {
                self.timer?.invalidate()
                self.timer = nil
                self.isRunning = false
                self.timerCompletedSubject.send()
            }
        }
    }
    
    deinit {
        timer?.invalidate()
    }
} 
