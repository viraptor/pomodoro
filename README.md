# Pomodoro Timer

A macOS Pomodoro timer application to help manage work and rest periods effectively. This app features a menu bar presence for easy control and configuration, along with usage statistics tracking.

## Features

- **Menu Bar Integration:** Quick access to timer controls and status from the menu bar.
    - Dynamic icon and text display reflecting the current state (Idle, Work, Rest).
    - Remaining time display (MM:SS).
    - Hover text with current state information.
- **Timer Functionality:**
    - Configurable work and rest durations.
    - Automatic and manual state transitions (Idle ↔ Work ↔ Rest).
    - Countdown timer with visual updates.
- **Configuration:**
    - Set custom work and rest durations.
    - Define active hours for reminders.
    - Settings saved persistently using UserDefaults.
- **Sound and Notifications:**
    - Audible alerts ("ding") at the end of work and rest periods.
    - System notifications for state completions.
    - Idle state reminders during active hours to encourage starting a work session.
- **Usage Statistics:**
    - Tracks completed Pomodoro sessions.
    - Aggregates statistics daily (number of sessions, total work time).
    - Stores statistics persistently.
    - Basic display of current day's and historical summary in the configuration window.
- **System Integration:**
    - Option to launch at login.
    - Graceful shutdown with data saving.
- **Error Handling:**
    - Robust error handling and logging.

## Technical Specifications

- **Language:** Swift 5.5+
- **UI Framework:** SwiftUI for macOS
- **Menu Bar:** `MenuBarExtra`
- **Data Persistence:** UserDefaults and Codable
- **Audio:** AVFoundation for sound playback
- **Notifications:** UserNotifications framework
- **Reactive Programming:** Combine framework
- **Testing:** XCTest for unit testing

## Build & Run

To build and run the project:

```bash
xcodebuild -scheme Pomodoro build && open -a Pomodoro
```

## Development Plan

The application is being developed in stages:

1.  **Basic Application Structure and State Management:** Setting up the project, state machine, and basic timer.
2.  **Menu Bar Integration:** Implementing the menu bar item and dropdown controls.
3.  **Timer Functionality and Display:** Enhancing timer display in the menu bar and state management logic.
4.  **Configuration Window:** Creating the UI and logic for user-configurable settings.
5.  **Sound and Notification System:** Adding audio alerts and system notifications.
6.  **Usage Statistics Tracking:** Implementing the collection, persistence, and display of usage data.
7.  **Polish and Integration:** Focusing on user experience, system integration (like start at login), and comprehensive error handling.

Each stage includes dedicated unit tests to ensure functionality and stability.
