//
//  PomodoroTests.swift
//  PomodoroTests
//
//  Created by Stan Pitucha on 26/4/2025.
//

import Testing
import XCTest
@testable import Pomodoro

struct PomodoroTests {
    @Test func testPomodoroStateTransitions() async throws {
        // Test state transitions using the next() method
        let idleState = PomodoroState.idle
        #expect(idleState.next() == .work)
        
        let workState = PomodoroState.work
        #expect(workState.next() == .rest)
        
        let restState = PomodoroState.rest
        #expect(restState.next() == .idle)
    }
    
    @Test func testPomodoroStateDescriptions() async throws {
        // Test state descriptions
        let idleState = PomodoroState.idle
        #expect(idleState.description == "Idle")
        #expect(idleState.actionText == "Start Work")
        
        let workState = PomodoroState.work
        #expect(workState.description == "Working")
        #expect(workState.actionText == "Take a Break")
        
        let restState = PomodoroState.rest
        #expect(restState.description == "Resting")
        #expect(restState.actionText == "End Break")
    }
    
    @Test func testAppSettingsValidation() async throws {
        // Test valid settings
        let validSettings = AppSettings.defaultSettings
        #expect(validSettings.isValid())
        
        // Test invalid work duration
        var invalidWorkDuration = AppSettings.defaultSettings
        invalidWorkDuration.workDuration = 0
        #expect(!invalidWorkDuration.isValid())
        
        // Test invalid rest duration
        var invalidRestDuration = AppSettings.defaultSettings
        invalidRestDuration.restDuration = -1
        #expect(!invalidRestDuration.isValid())
        
        // Test invalid active hours
        var invalidActiveHours = AppSettings.defaultSettings
        invalidActiveHours.activeHoursStart = 24
        #expect(!invalidActiveHours.isValid())
    }
    
    @Test func testTimerServiceBasicFunctionality() async throws {
        let timerService = TimerService()
        
        // Test initial state
        #expect(!timerService.isRunning)
        #expect(timerService.remainingTime == 0)
        
        // Test starting timer
        timerService.start(duration: 10)
        #expect(timerService.isRunning)
        #expect(timerService.remainingTime == 10)
        
        // Test pausing timer
        timerService.pause()
        #expect(!timerService.isRunning)
        
        // Test resuming timer
        timerService.resume()
        #expect(timerService.isRunning)
        
        // Test resetting timer
        timerService.reset()
        #expect(!timerService.isRunning)
        #expect(timerService.remainingTime == 10)
    }
    
    @Test func testStateManagerInitialState() async throws {
        let stateManager = StateManager()
        
        // Test initial state
        #expect(stateManager.currentState == .idle)
        
        // Test settings
        #expect(stateManager.settings.workDuration == 25)
        #expect(stateManager.settings.restDuration == 5)
    }
}
