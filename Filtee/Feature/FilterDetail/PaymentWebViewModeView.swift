//
//  PaymentWebViewModeView.swift
//  Filtee
//
//  Created by 김도형 on 6/16/25.
//

import Foundation
import SwiftUI
import WebKit
import iamport_ios


struct PaymentWebViewModeView: UIViewControllerRepresentable {
    @Environment(\.iamportClient.requestPayment)
    private var iamportRequestPayment
    @Environment(\.iamportClient.close)
    private var iamportClose
    
    private let payload: IamportPaymentPayloadModel
    
    init(payload: IamportPaymentPayloadModel) {
        self.payload = payload
    }
    
    func makeUIViewController(context: Context) -> PaymentWebViewModeViewController {
        return PaymentWebViewModeViewController(
            payload: payload,
            iamportRequestPayment: iamportRequestPayment,
            iamportClose: iamportClose
        )
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
}

final class PaymentWebViewModeViewController: UIViewController, WKNavigationDelegate {
    private let payload: IamportPaymentPayloadModel
    private let iamportRequestPayment: @Sendable (
        _ wkWebView: WKWebView,
        _ payload: IamportPaymentPayloadModel
    ) async -> Void
    private let iamportClose: @Sendable () async -> Void
    
    private lazy var wkWebView: WKWebView = {
        var view = WKWebView()
        view.backgroundColor = UIColor.clear
        view.navigationDelegate = self
        return view
    }()
    
    init(
        payload: IamportPaymentPayloadModel,
        iamportRequestPayment: @Sendable @escaping (
            _ wkWebView: WKWebView,
            _ payload: IamportPaymentPayloadModel
        ) async -> Void,
        iamportClose: @Sendable @escaping () async -> Void
    ) {
        self.payload = payload
        self.iamportRequestPayment = iamportRequestPayment
        self.iamportClose = iamportClose
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func attachWebView() {
        print("attachWebView")
        view.addSubview(wkWebView)
        wkWebView.frame = view.frame

        wkWebView.translatesAutoresizingMaskIntoConstraints = false
        wkWebView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        wkWebView.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        wkWebView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        wkWebView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }

    private func removeWebView() {
        view.willRemoveSubview(wkWebView)
        wkWebView.stopLoading()
        wkWebView.removeFromSuperview()
        wkWebView.uiDelegate = nil
        wkWebView.navigationDelegate = nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        print("PaymentWebViewModeView viewDidLoad")

        view.backgroundColor = UIColor.white
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("PaymentWebViewModeView viewDidAppear")
        attachWebView()
        Task { [weak self] in
            guard let `self` else { return }
            await iamportRequestPayment(wkWebView, payload)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("PaymentWebViewModeView viewWillDisappear")
        removeWebView()
        Task { await iamportClose() }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("PaymentWebViewModeView viewDidDisappear")
    }
}
