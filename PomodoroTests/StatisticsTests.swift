import XCTest
@testable import Pomodoro

final class StatisticsTests: XCTestCase {
    var statisticsManager: StatisticsManager!
    
    override func setUp() {
        super.setUp()
        statisticsManager = StatisticsManager()
        // Clear any existing stats for clean tests
        statisticsManager.resetStatistics()
    }
    
    override func tearDown() {
        statisticsManager = nil
        super.tearDown()
    }
    
    func testStartAndCompleteSession() {
        // Test that a session can be properly started and completed
        XCTAssert(statisticsManager.dailyStats.isEmpty, "Stats should start empty")
        
        statisticsManager.startWorkSession()
        // Simulate some work time
        Thread.sleep(forTimeInterval: 0.1)
        statisticsManager.completeWorkSession()
        
        XCTAssertEqual(statisticsManager.dailyStats.count, 1, "Should have one day of stats")
        XCTAssertEqual(statisticsManager.dailyStats[0].sessions.count, 1, "Should have one session")
        XCTAssertGreaterThan(statisticsManager.dailyStats[0].sessions[0].duration, 0, "Session duration should be positive")
    }
    
    func testMultipleSessions() {
        // Test recording multiple sessions
        for _ in 1...3 {
            statisticsManager.startWorkSession()
            Thread.sleep(forTimeInterval: 0.05)
            statisticsManager.completeWorkSession()
        }
        
        XCTAssertEqual(statisticsManager.dailyStats.count, 1, "Should have one day of stats")
        XCTAssertEqual(statisticsManager.dailyStats[0].sessions.count, 3, "Should have three sessions")
    }
    
    func testTodayStats() {
        // Test that today's stats are correctly identified
        XCTAssertNil(statisticsManager.todayStats, "Today stats should be nil when no sessions")
        
        // Add a session for today
        let today = Calendar.current.startOfDay(for: Date())
        let startTime = Date()
        let endTime = startTime.addingTimeInterval(3600) // 1 hour
        let session = WorkSession(startTime: startTime, endTime: endTime)
        
        // Add the session directly to statistics manager
        statisticsManager.setDailyStats([DailyStatistics(date: today, sessions: [session])])
        
        XCTAssertNotNil(statisticsManager.todayStats, "Today stats should be available")
        XCTAssertEqual(statisticsManager.todayStats?.completedSessionsCount, 1, "Should have one completed session today")
    }
    
    func testDailyStatisticsFormatting() {
        // Create a test session with a known duration
        let startTime = Date()
        let endTime = startTime.addingTimeInterval(3600) // 1 hour
        let session = WorkSession(startTime: startTime, endTime: endTime)
        
        // Manually add the session
        let today = Calendar.current.startOfDay(for: Date())
        let dailyStats = DailyStatistics(date: today, sessions: [session])
        
        XCTAssertEqual(dailyStats.totalWorkTime, 3600, "Should be 1 hour (3600 seconds)")
        XCTAssertEqual(dailyStats.formattedTotalWorkTime, "01:00", "Should format as 01:00")
    }
} 
