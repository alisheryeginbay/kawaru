@preconcurrency import UserNotifications

enum NotificationHelper {
    private static let categoryID = "INPUT_SOURCE_CHANGED"

    static func send(sourceName: String) {
        Task {
            let center = UNUserNotificationCenter.current()

            let granted = try? await center.requestAuthorization(options: [.alert])
            guard granted == true else { return }

            let content = UNMutableNotificationContent()
            content.title = "Kawaru"
            content.body = "Switched to \(sourceName)"

            let request = UNNotificationRequest(
                identifier: categoryID,
                content: content,
                trigger: nil
            )

            try? await center.add(request)
        }
    }
}
