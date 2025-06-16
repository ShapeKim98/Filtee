//
//  IamportManager.swift
//  Filtee
//
//  Created by 김도형 on 6/16/25.
//

import Foundation
import WebKit

import Then
@preconcurrency import iamport_ios

@MainActor
final class IamportManager {
    var continuation: CheckedContinuation<IamportResponse?, Error>?

    func requestPayment(
        wkWebView: WKWebView,
        orderCode: String,
        price: Int,
        name: String,
        buyerName: String
    ) {
        guard let payment = createPaymentData(
            orderCode: orderCode,
            price: price,
            name: name,
            buyerName: buyerName
        ) else { return }
        
        Iamport.shared.paymentWebView(
            webViewMode: wkWebView,
            userCode: "imp14511373",
            payment: payment
        ) { [weak self] iamportResponse in
            Task { @Sendable [weak self] in
                if let error = iamportResponse?.error_msg {
                    let error = NSError(domain: error, code: -1)
                    self?.continuation?.resume(throwing: error)
                }
                self?.continuation?.resume(returning: iamportResponse)
            }
        }
    }
    
    func requestIamport() async throws -> IamportResponse? {
        try await withCheckedThrowingContinuation { [weak self] continuation in
            self?.configureContinuation(continuation)
        }
    }
    
    private func configureContinuation(
        _ continuation: CheckedContinuation<IamportResponse?, Error>?
    ) {
        self.continuation = continuation
    }

    // 아임포트 결제 데이터 생성
    private func createPaymentData(
        orderCode: String,
        price: Int,
        name: String,
        buyerName: String
    ) -> IamportPayment? {
        let req = IamportPayment(
                pg: PG.html5_inicis.makePgRawName(pgId: "INIpayTest"),
                merchant_uid: orderCode,
                amount: String(price)
        ).then {
            $0.pay_method = PayMethod.card.rawValue
            $0.name = name
            $0.buyer_name = buyerName
            $0.app_scheme = "filtee"
        }

        return req
    }
    
    func close() {
        continuation = nil
        Iamport.shared.close()
    }
}
