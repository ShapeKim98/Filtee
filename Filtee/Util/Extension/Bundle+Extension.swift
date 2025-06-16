//
//  Bundle+Extension.swift
//  Filtee
//
//  Created by 김도형 on 5/18/25.
//

import Foundation

extension Bundle {
    var baseURL: String {
        infoDictionary?["BASE_URL"] as? String ?? ""
    }
    
    var sesacKey: String {
        infoDictionary?["SESAC_KEY"] as? String ?? ""
    }
    
    var kakaoNativeAppKey: String {
        infoDictionary?["KAKAO_NATIVE_APP_KEY"] as? String ?? ""
    }
    
    var appleKeyId: String {
        infoDictionary?["APPLE_KEY_ID"] as? String ?? ""
    }
    
    var teamId: String {
        infoDictionary?["TEAM_ID"] as? String ?? ""
    }
}
