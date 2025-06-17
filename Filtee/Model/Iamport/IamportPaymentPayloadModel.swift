//
//  IamportPaymentPayloadModel.swift
//  Filtee
//
//  Created by 김도형 on 6/16/25.
//


import Foundation
import WebKit
import Then
import iamport_ios

struct IamportPaymentPayloadModel: Identifiable {
    let id: String = UUID().uuidString
    let orderCode: String
    let price: Int
    let name: String
    let buyerName: String
}
