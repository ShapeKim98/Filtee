//
//  NotificationPayload.swift
//  Filtee
//
//  Created by 김도형 on 7/23/25.
//

import Foundation

struct NotificationPayload: ResponseDTO {
    let title: String
    let subtitle: String?
    let body: String
}
