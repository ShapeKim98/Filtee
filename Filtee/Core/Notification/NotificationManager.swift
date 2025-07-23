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
    static let shared = NotificationManager()
    
    private override init() { super.init() }
    
    nonisolated(unsafe)
    private var continuation: AsyncThrowingStream<NotificationPayload, Error>.Continuation?
    nonisolated(unsafe)
    private var queue = [NotificationPayload]()
    
    func requestAuthorization() async throws -> Bool {
        UNUserNotificationCenter.current().delegate = self
        
        return try await withCheckedThrowingContinuation { continuation in
            UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .badge, .sound],
                completionHandler: { granted, error in
                    if let error {
                        continuation.resume(throwing: error)
                        return
                    }
                    continuation.resume(returning: granted)
                }
            )
        }
    }
    
    func payloadStream() -> AsyncThrowingStream<NotificationPayload, Error> {
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
