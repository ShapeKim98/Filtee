//
//  NotificationManager.swift
//  Filtee
//
//  Created by 김도형 on 7/23/25.
//

import SwiftUI
import Combine

import UserNotifications

actor NotificationManager: NSObject {
    nonisolated(unsafe)
    private var continuation: AsyncThrowingStream<NotificationPayload, Error>.Continuation?
    nonisolated(unsafe)
    private var queue = [NotificationPayload]()
    
    @MainActor
    func requestAuthorization(
        _ application: UIApplication
    ) {
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )
        application.registerForRemoteNotifications()
    }
    
    func userInfoPublisher() -> AsyncThrowingStream<NotificationPayload, Error> {
        return AsyncThrowingStream { [weak self] continuation in
            if let last = self?.queue.last {
                continuation.yield(last)
            }
            self?.queue.removeAll()
            self?.continuation = continuation
        }
    }
    
    nonisolated func getAuthorizationStatus() async -> UNAuthorizationStatus {
        await UNUserNotificationCenter.current().notificationSettings().authorizationStatus
    }
}

extension NotificationManager: UNUserNotificationCenterDelegate {
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .list, .sound])
    }
    
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        print(userInfo)
        guard let aps = userInfo["aps"] else { return }
        do {
            let jsonData = try JSONSerialization.data(
                withJSONObject: aps,
                options: []
            )
            let notification = try JSONDecoder().decode(
                NotificationPayload.self,
                from: jsonData
            )
            if continuation == nil {
                queue.append(notification)
            } else {
                continuation?.yield(notification)
            }
        } catch {
            continuation?.finish(throwing: error)
        }
        
        completionHandler()
    }
}

extension NotificationManager: EnvironmentKey {
    static let defaultValue = NotificationManager()
}

extension EnvironmentValues {
    var notificationManager: NotificationManager {
        get { self[NotificationManager.self] }
        set { self[NotificationManager.self] = newValue }
    }
}
