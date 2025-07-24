//
//  BannerWebView.swift
//  Filtee
//
//  Created by 김도형 on 7/24/25.
//

import SwiftUI
import WebKit

struct BannerWebView: View {
    @EnvironmentObject
    private var navigation: NavigationRouter<MainPath>
    
    @Environment(\.keychainManager)
    private var keychainManager
    @Environment(\.authClient.refresh)
    private var authClientRefresh
    
    
    var body: some View {
        WebBridgeView()
            .addContentEvent(
                "click_attendance_button",
                handler: clickAttendanceButton
            )
            .addContentEvent(
                "complete_attendance",
                handler: completeAttendance
            )
            .addContentEvent(
                "attendance_fail",
                handler: attendanceFailed
            )
            .addTextObserver(
                "회원 정보를 찾을 수 없습니다",
                event: "attendance_fail"
            )
            .ignoresSafeArea(.all, edges: .bottom)
            .filteeNavigation(
                title: "",
                leadingItems: leadingItems
            )
    }
}

// MARK: - Configure Views
private extension BannerWebView {
    func leadingItems() -> some View {
        Button(action: backButtonAction) {
            Image(.chevron)
                .resizable()
        }
        .buttonStyle(.filteeToolbar)
    }
}

// MARK: - Functions
private extension BannerWebView {
    func clickAttendanceButton(_ message: WKScriptMessage) async {
        do {
            let accessToken = keychainManager.read(.accessToken) ?? ""
            let javascript = "requestAttendance('\(accessToken)')"
            try await message.webView?.evaluateJavaScript(javascript)
        } catch {
            print(error)
        }
    }
    
    func completeAttendance(_ message: WKScriptMessage) async {
        
    }
    
    func attendanceFailed(_ message: WKScriptMessage) async {
        do {
            try await authClientRefresh()
            message.webView?.reload()
        } catch {
            print(error)
        }
    }
    
    func backButtonAction() {
        navigation.pop()
    }
}

#Preview {
    BannerWebView()
}
