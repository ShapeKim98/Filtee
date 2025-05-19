//
//  SocialLoginManager.swift
//  Filtee
//
//  Created by 김도형 on 5/19/25.
//

import Foundation
import AuthenticationServices

import KakaoSDKAuth
import KakaoSDKUser
import SwiftJWT

@MainActor
final class SocialLoginManager: NSObject {
    private var continuation: CheckedContinuation<SocialLoginResponse, Error>?
    
    func kakaoLogin() async throws -> SocialLoginResponse {
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            self?.continuation = continuation
            self?.requestKakaoLogin()
        }
    }
    
    func appleLogin() async throws -> SocialLoginResponse {
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            self?.continuation = continuation
            self?.requestAppleLogin()
        }
    }
    
    func requestKakaoLogin() {
        if UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoTalk(completion: handleKakaoLogin)
            print("loginWithKakaoTalk() success.")
        } else {
            UserApi.shared.loginWithKakaoAccount(completion: handleKakaoLogin)
            print("loginWithKakaoAccount() success.")
        }
    }
    
    func handleKakaoLogin(oauthToken: OAuthToken?, error: Error?) {
        if let error {
            print(error)
            self.continuation?.resume(throwing: error)
            continuation = nil
        }
        
        // 성공 시 동작 구현
        guard let idToken = oauthToken?.idToken else { return }
        continuation?.resume(returning: SocialLoginResponse(
            token: idToken
        ))
        continuation = nil
    }
    
    func withdrawKakaoLogin() {
        UserApi.shared.unlink {(error) in
            if let error = error {
                print(error)
            } else {
                print("unlink() success.")
            }
        }
    }
}


extension SocialLoginManager: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func requestAppleLogin() {
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = []
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.keyWindow
        else { return UIWindow() }
        
        return window
    }
    
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard
            let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
            let idToken = appleIDCredential.identityToken,
            let authorizationCode = appleIDCredential.authorizationCode,
            let idTokenString = String(data: idToken, encoding: .utf8),
            let authorizationCodeString = String(data: authorizationCode, encoding: .utf8),
            let nickname = appleIDCredential.fullName?.nickname
        else { return }
        
        print("🍎 [appleLogin] token: \(idTokenString)")
        print("🍎 [appleLogin] authorizationCode: \(authorizationCodeString)")
        
        continuation?.resume(returning: SocialLoginResponse(
            token: idTokenString,
            nick: nickname,
            authorizationCode: authorizationCodeString
        ))
        continuation = nil
    }
    
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        continuation?.resume(throwing: error)
        continuation = nil
    }
    
    func makeJWT() -> String {
        let header = Header(kid: Bundle.main.appleKeyId)
        print(header)
        struct FilteeClaims: Claims {
            let iss: String
            let iat: Int
            let exp: Int
            let aud: String
            let sub: String
        }
        
        let iat = Int(Date().timeIntervalSince1970)
        let exp = iat + 3600
        let iss = Bundle.main.teamId
        print(iss)
        let claims = FilteeClaims(
            iss: iss,
            iat: iat,
            exp: exp,
            aud: "https://appleid.apple.com",
            sub: "com.dohyeong.Filtee"
        )
        
        var myJWT = JWT(header: header, claims: claims)
        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: "AuthKey", withExtension: "p8") else {
            return "못찾음"
        }
        let privateKey: Data = try! Data(contentsOf: url, options: .alwaysMapped)
        
        let jwtSigner = JWTSigner.es256(privateKey: privateKey)
        let signedJWT = try! myJWT.sign(using: jwtSigner)
        
        return signedJWT
    }
}
