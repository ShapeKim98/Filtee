//
//  LoginView.swift
//  Filtee
//
//  Created by 김도형 on 5/19/25.
//

import SwiftUI

struct LoginView: View {
    @Environment(\.userClient.kakaoLogin)
    private var userClientKakaoLogin
    @Environment(\.userClient.appleLogin)
    private var userClientAppleLogin
    @Environment(\.socialLoginClient.kakaoLogin)
    private var socialLoginClientKakaoLogin
    @Environment(\.socialLoginClient.appleLogin)
    private var socialLoginClientAppleLogin
    
    @EnvironmentObject
    private var rootRouter: FlowRouter<Root>
    
    @State
    private var isLoading = false
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Text("Filtee")
                .font(.mulgyeol(.custom("B", 80)))
                .foregroundStyle(.gray15)
            
            Spacer()
            
            Button(action: kakaoLoginButtonAction) {
                socialLoginButtonLabel(
                    icon: .kakao,
                    title: "카카오로 시작하기",
                    color: .kakaoYellow
                )
            }
            
            Button(action: appleLoginButtonAction) {
                socialLoginButtonLabel(
                    icon: .apple,
                    title: "애플로 시작하기",
                    color: .gray0
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 88)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .filteeBackground()
        .background(.blackTurquoise)
        .ignoresSafeArea()
        .if(isLoading) { $0.overlay {
            ProgressView()
                .controlSize(.large)
        }}
    }
}

// MARK: - Configure Views
private extension LoginView {
    func socialLoginButtonLabel(
        icon: ImageResource,
        title: String,
        color: Color
    ) -> some View {
        HStack {
            Image(icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
            
            Text(title)
                .font(.pretendard(.body2(.medium)))
        }
        .foregroundStyle(.gray100)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity)
        .background(color)
    }
}

// MARK: - Functions
private extension LoginView {
    func kakaoLoginButtonAction() {
        Task {
            isLoading = true
            defer { isLoading = false }
            do {
                let model = try await socialLoginClientKakaoLogin()
                let kakaoLoginModel = KakaoLoginModel(oauthToken: model.token)
                try await userClientKakaoLogin(kakaoLoginModel)
                rootRouter.switch(.tab)
            } catch {
                print(error)
            }
        }
    }
    
    func appleLoginButtonAction() {
        Task {
            isLoading = true
            defer { isLoading = false }
            do {
                let model = try await socialLoginClientAppleLogin()
//                try await socialLoginClient.appleToken()
                let appleLoginModel = AppleLoginModel(
                    idToken: model.token,
                    nick: model.nick
                )
                try await userClientAppleLogin(appleLoginModel)
                rootRouter.switch(.tab)
            } catch {
                print(error)
            }
        }
    }
}

#Preview {
    LoginView()
        .environment(\.userClient, .testValue)
        .environment(\.socialLoginClient, .testValue)
}
