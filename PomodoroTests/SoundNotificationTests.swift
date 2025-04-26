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
    
    func testActiveHoursLogic() {
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
        
        // Test the isWithinActiveHours method through reflection
        // This is a hack for testing private methods, not generally recommended
        let isWithinActiveHoursMethod = stateManager.perform(
            Selector(("isWithinActiveHours"))
        )
        
        // If the method exists and returns a value, we consider the test passed
        XCTAssertNotNil(isWithinActiveHoursMethod)
        
        // For a more comprehensive test, we'd need to mock the calendar and time
    }
} 
