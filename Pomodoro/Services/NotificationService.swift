import Foundation
import UserNotifications

/// Service that manages notifications for the Pomodoro app
class NotificationService {
    /// Notification identifier types
    enum NotificationType: String {
        case workComplete = "work-complete"
        case restComplete = "rest-complete"
        case idleReminder = "idle-reminder"
    }
    
    /// Initialize the notification service and request permissions
    init() {
        requestPermission()
    }
    
    /// Request notification permission from the user
    func requestPermission() {
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification authorization error: \(error.localizedDescription)")
                return
            }
            
            if granted {
                print("Notification permission granted")
            } else {
                print("Notification permission denied")
            }
        }
    }
    
    /// Send a work session completed notification
    func notifyWorkComplete() {
        sendNotification(
            type: .workComplete,
            title: "Work Session Complete",
            body: "Good job! Time to take a break.",
            timeInterval: 1
        )
    }
    
    /// Send a rest session completed notification
    func notifyRestComplete() {
        sendNotification(
            type: .restComplete,
            title: "Break Time Over",
            body: "Ready to get back to work?",
            timeInterval: 1
        )
    }
    
    /// Send an idle reminder notification
    /// - Parameter timeToNextReminder: Time in seconds until the next reminder
    func notifyIdleReminder(timeToNextReminder: TimeInterval) {
        sendNotification(
            type: .idleReminder,
            title: "Pomodoro Timer Idle",
            body: "Ready to start a new work session?",
            timeInterval: 1
        )
    }
    
    /// Generic method to send a notification
    /// - Parameters:
    ///   - type: The type of notification
    ///   - title: The notification title
    ///   - body: The notification body text
    ///   - timeInterval: Time interval in seconds before showing the notification
    private func sendNotification(type: NotificationType, title: String, body: String, timeInterval: TimeInterval) {
        let center = UNUserNotificationCenter.current()
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default
        
        // Create trigger
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        
        // Create request with unique identifier
        let identifier = "\(type.rawValue)-\(Date().timeIntervalSince1970)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        // Add the request
        center.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    /// Remove any pending notifications of a specific type
    /// - Parameter type: The type of notifications to remove
    func removePendingNotifications(ofType type: NotificationType) {
        let center = UNUserNotificationCenter.current()
        
        center.getPendingNotificationRequests { requests in
            let identifiersToRemove = requests.filter { 
                $0.identifier.hasPrefix(type.rawValue) 
            }.map { $0.identifier }
            
            center.removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
        }
    }
    
    /// Remove all pending notifications
    func removeAllPendingNotifications() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()
    }
} 
