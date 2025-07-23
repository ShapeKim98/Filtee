//
//  FirebaseManager.swift
//  Filtee
//
//  Created by 김도형 on 7/23/25.
//

import SwiftUICore

import Firebase
import FirebaseMessaging

actor FirebaseManager: NSObject {
    static let shared = FirebaseManager()
    
    private override init() { }
    
    @MainActor
    func configureFirebase() {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        Messaging.messaging().isAutoInitEnabled = true
    }
    
    @MainActor
    func updateAPNSToken(_ deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func fetchFCMToken() async throws -> String {
        let fcmToken = try await Messaging.messaging().token()
        return fcmToken
    }
}

extension FirebaseManager: MessagingDelegate {
    nonisolated func messaging(
        _ messaging: Messaging,
        didReceiveRegistrationToken fcmToken: String?
    ) {
        print("fcmToken: \(fcmToken)")
    }
}

extension FirebaseManager: EnvironmentKey {
    static let defaultValue = FirebaseManager()
}

extension EnvironmentValues {
    var firebaseManager: FirebaseManager {
        get { self[FirebaseManager.self] }
        set { self[FirebaseManager.self] = newValue }
    }
}
