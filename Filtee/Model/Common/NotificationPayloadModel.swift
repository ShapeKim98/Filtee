//
//  NotificationPayloadModel.swift
//  Filtee
//
//  Created by 김도형 on 7/23/25.
//

import Foundation

struct NotificationPayloadModel {
    let title: String
    let subtitle: String?
    let body: String
}

extension NotificationPayloadModel {
    func toData() -> NotificationPayload {
        return NotificationPayload(
            title: self.title,
            subtitle: self.subtitle,
            body: self.body
        )
    }
}

extension NotificationPayload {
    func toModel() -> NotificationPayloadModel {
        return NotificationPayloadModel(
            title: self.title,
            subtitle: self.subtitle,
            body: self.body
        )
    }
}
