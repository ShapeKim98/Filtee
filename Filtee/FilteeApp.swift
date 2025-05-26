//
//  FilteeApp.swift
//  Filtee
//
//  Created by 김도형 on 5/11/25.
//

import SwiftUI

import Alamofire
import KakaoSDKCommon
import Nuke
import NukeAlamofirePlugin

@main
struct FilteeApp: App {
    init() {
        KakaoSDK.initSDK(appKey: Bundle.main.kakaoNativeAppKey)
        
        let pipeline = ImagePipeline {
            $0.dataLoader = AlamofireDataLoader(session: imageSession)
            $0.imageCache = ImageCache.shared
            $0.dataCachePolicy = .automatic
        }

        ImagePipeline.shared = pipeline
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
