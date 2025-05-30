import XCTest
@testable import Pomodoro

final class SoundNotificationTests: XCTestCase {
    
    func testSoundServiceInitialization() {
        // Test that the sound service can be initialized without crashing
        let soundService = SoundService()
        XCTAssertNotNil(soundService)
    }
    
    func testNotificationServiceInitialization() {
        // Test that the notification service can be initialized without crashing
        let notificationService = NotificationService()
        XCTAssertNotNil(notificationService)
    }
    
    func testStateManagerWithSoundAndNotifications() {
        // Create mock services
        let timerService = TimerService()
        let soundService = SoundService()
        let notificationService = NotificationService()
        
        // Create state manager with mock services
        let stateManager = StateManager(
            timerService: timerService,
            soundService: soundService,
            notificationService: notificationService
        )
        
        // Verify initial state
        XCTAssertEqual(stateManager.currentState, .idle)
        
        // Verify advancing to work state
        stateManager.advance()
        XCTAssertEqual(stateManager.currentState, .work)
        
        // Verify that timer service received the correct duration
        XCTAssertEqual(stateManager.remainingTime, TimeInterval(stateManager.settings.workDurationSeconds))
        
        // Test more state transitions would ideally include mocking sound playback and notification delivery
        // but that would require more complex test infrastructure
    }
    
    func testActiveHoursConfiguration() {
        // Create mock services with a test configuration
        let timerService = TimerService()
        let soundService = SoundService()
        let notificationService = NotificationService()
        
        // Create state manager with mock services
        let stateManager = StateManager(
            timerService: timerService,
            soundService: soundService,
            notificationService: notificationService
        )
        
        // Test that we can set and get active hours settings
        var settings = stateManager.settings
        settings.activeHoursStart = 9 // 9 AM
        settings.activeHoursEnd = 17 // 5 PM
        stateManager.settings = settings
        
        XCTAssertEqual(stateManager.settings.activeHoursStart, 9)
        XCTAssertEqual(stateManager.settings.activeHoursEnd, 17)
    }
    
    func testIdleReminderTimerInvalidationAndResetting() {
        // Create mock services
        let timerService = TimerService()
        let soundService = SoundService()
        let notificationService = NotificationService()
        
        // Create state manager
        let stateManager = StateManager(
            timerService: timerService,
            soundService: soundService,
            notificationService: notificationService
        )
        
        // 1. Initial state: Idle. Timer should be active.
        XCTAssertNotNil(stateManager.idleReminderTimer, "Idle reminder timer should be active in Idle state initially.")
        XCTAssertTrue(stateManager.idleReminderTimer?.isValid ?? false, "Idle reminder timer should be valid in Idle state initially.")

        // 2. Advance to Work state. Timer should be invalidated.
        stateManager.advance() // Idle -> Work
        XCTAssertEqual(stateManager.currentState, .work, "State should be Work.")
        XCTAssertNil(stateManager.idleReminderTimer, "Idle reminder timer should be nil after starting Work.")
        
        // 3. Advance to Rest state. Timer should still be nil.
        stateManager.advance() // Work -> Rest
        XCTAssertEqual(stateManager.currentState, .rest, "State should be Rest.")
        XCTAssertNil(stateManager.idleReminderTimer, "Idle reminder timer should remain nil during Rest.")
        
        // 4. Advance back to Idle state. A new timer should be set up.
        stateManager.advance() // Rest -> Idle
        XCTAssertEqual(stateManager.currentState, .idle, "State should be Idle.")
        XCTAssertNotNil(stateManager.idleReminderTimer, "Idle reminder timer should be re-initialized when returning to Idle state.")
        XCTAssertTrue(stateManager.idleReminderTimer?.isValid ?? false, "New idle reminder timer should be valid.")
    }
} 
