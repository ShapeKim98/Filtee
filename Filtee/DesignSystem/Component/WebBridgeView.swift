//
//  WebView.swift
//  Filtee
//
//  Created by 김도형 on 7/23/25.
//

import SwiftUI
import WebKit

struct WebBridgeView: UIViewRepresentable {
    typealias MessageHandler = (WKScriptMessage) async -> Void
    
    @Binding
    private var isLoading: Bool
    private let userContentEvents: [String: MessageHandler]
    private let observerScripts: [String]
    private let onError: ((Error) -> Void)?
    
    private init(
        isLoading: Binding<Bool>,
        userContentEvents: [String: MessageHandler],
        observerScript: [String],
        onError: ((Error) -> Void)?
    ) {
        self._isLoading = isLoading
        self.userContentEvents = userContentEvents
        self.observerScripts = observerScript
        self.onError = onError
    }
    
    init() {
        self._isLoading = .constant(false)
        self.userContentEvents = [:]
        self.observerScripts = []
        self.onError = nil
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        // 웹뷰 설정
        let webConfiguration = WKWebViewConfiguration()
        let userContentController = WKUserContentController()
        
        // 메시지 핸들러 등록
        userContentEvents.keys.forEach { name in
            userContentController.add(context.coordinator, name: name)
        }
        
        observerScripts.forEach { observerScript in
            let userScript = WKUserScript(
                source: observerScript,
                injectionTime: .atDocumentEnd,
                forMainFrameOnly: true
            )
            userContentController.addUserScript(userScript)
        }
        
        webConfiguration.userContentController = userContentController
        
        // 웹뷰 생성
        let webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.navigationDelegate = context.coordinator
        
        // 웹뷰 로드
        loadWebView(webView)
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        // 필요시 웹뷰 업데이트
    }
    
    func addContentEvent(
        _ name: String,
        handler: @escaping MessageHandler
    ) -> Self {
        var newContentEvents = userContentEvents
        newContentEvents[name] = handler
        
        return WebBridgeView(
            isLoading: self.$isLoading,
            userContentEvents: newContentEvents,
            observerScript: self.observerScripts,
            onError: self.onError
        )
    }
    
    func onError(_ perform: @escaping (Error) -> Void) -> Self {
        WebBridgeView(
            isLoading: self.$isLoading,
            userContentEvents: self.userContentEvents,
            observerScript: self.observerScripts,
            onError: perform
        )
    }
    
    func onLoading(_ isLoading: Binding<Bool>) -> Self {
        WebBridgeView(
            isLoading: isLoading,
            userContentEvents: self.userContentEvents,
            observerScript: self.observerScripts,
            onError: self.onError
        )
    }
    
    func addTextObserver(_ text: String, event: String) -> Self {
        let observerScript = """
        var observer = new MutationObserver(function(mutations) {
            if (document.body.innerText.includes('\(text)')) {
                window.webkit.messageHandlers.\(event).postMessage('error_detected');
                observer.disconnect();
            }
        });
        observer.observe(document.body, { childList: true, subtree: true, characterData: true });
        """
        
        return WebBridgeView(
            isLoading: self.$isLoading,
            userContentEvents: self.userContentEvents,
            observerScript: observerScripts + [observerScript],
            onError: self.onError
        )
    }
    
    private func loadWebView(_ webView: WKWebView) {
        guard let url = URL(string: Bundle.main.baseURL + "/event-application") else {
            return
        }
        
        var request = URLRequest(url: url)
        // SeSACKey 헤더 추가 (필수)
        request.setValue(Bundle.main.sesacKey, forHTTPHeaderField: "SeSACKey")
        
        webView.load(request)
    }
}

// MARK: - Coordinator
extension WebBridgeView {
    class Coordinator: NSObject, WKScriptMessageHandler, WKNavigationDelegate {
        var parent: WebBridgeView
        
        init(_ parent: WebBridgeView) {
            self.parent = parent
        }
        
        // MARK: - WKScriptMessageHandler
        func userContentController(
            _ userContentController: WKUserContentController,
            didReceive message: WKScriptMessage
        ) {
            print(message.body, message.name)
            Task { [weak self] in
                await self?.parent.userContentEvents[message.name]?(message)
            }
        }
        
        // MARK: - WKNavigationDelegate
        func webView(
            _ webView: WKWebView,
            didStartProvisionalNavigation navigation: WKNavigation!
        ) {
            parent.isLoading = true
        }
        
        func webView(
            _ webView: WKWebView,
            didFinish navigation: WKNavigation!
        ) {
            parent.isLoading = false
        }
        
        func webView(
            _ webView: WKWebView,
            didFail navigation: WKNavigation!,
            withError error: Error
        ) {
            parent.isLoading = false
            parent.onError?(error)
        }
    }
}
