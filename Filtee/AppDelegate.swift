//
//  AppDelegate.swift
//  Filtee
//
//  Created by 김도형 on 7/23/25.
//

import SwiftUI

final class AppDelegate: NSObject, UIApplicationDelegate {
    @Environment(\.firebaseManager)
    private var firebaseManager
    @Environment(\.notificationManager)
    private var notificationManager
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        firebaseManager.configureFirebase()
        notificationManager.requestAuthorization(application)
        
        return true
    }
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let tokenParts = deviceToken.map { data in
            String(format: "%02.2hhx", data)
        }
        let token = tokenParts.joined()
        print("APNs Device Token: \(token)")
        firebaseManager.updateAPNSToken(deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: any Error) {
        print("fail: \(#function) -> \(error)")
    }
}
