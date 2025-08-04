//
//  FilteeApp.swift
//  Filtee
//
//  Created by 김도형 on 5/11/25.
//

import SwiftUI

import Alamofire
import KakaoSDKCommon
import KakaoSDKAuth
import Nuke
import NukeAlamofirePlugin

@main
struct FilteeApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self)
    var appDelegate
    
    init() {
        KakaoSDK.initSDK(appKey: Bundle.main.kakaoNativeAppKey)
        
        let pipeline = ImagePipeline {
            $0.dataLoader = AlamofireDataLoader(session: defaultSession)
            $0.imageCache = ImageCache.shared
            $0.dataCachePolicy = .automatic
            $0.isRateLimiterEnabled = true
        }

        ImagePipeline.shared = pipeline
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .onOpenURL { url in
                    guard AuthApi.isKakaoTalkLoginUrl(url) else { return }
                    let _ = AuthController.handleOpenUrl(url: url)
                }
        }
    }
}

// - MARK: 네비게이션 뒤로가기 제스처
extension UINavigationController: @retroactive UIGestureRecognizerDelegate {
    open override func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer.isEqual(self.interactivePopGestureRecognizer)
    }
}
