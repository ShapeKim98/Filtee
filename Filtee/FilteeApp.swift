//
//  FilteeApp.swift
//  Filtee
//
//  Created by 김도형 on 5/11/25.
//

import SwiftUI

import KakaoSDKCommon

@main
struct FilteeApp: App {
    init() {
        KakaoSDK.initSDK(appKey: Bundle.main.kakaoNativeAppKey)
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
