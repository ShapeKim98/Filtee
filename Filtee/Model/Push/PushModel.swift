//
//  PushModel.swift
//  Filtee
//
//  Created by 김도형 on 7/23/25.
//

import Foundation

struct PushModel {
    let userIds: [String]
    let title: String
    let subtitle: String?
    let body: String
    
    init(
        userIds: [String],
        title: String,
        subtitle: String? = nil,
        body: String
    ) {
        self.userIds = userIds
        self.title = title
        self.subtitle = subtitle
        self.body = body
    }
}

extension PushModel {
    func toData() -> PushRequest {
        return PushRequest(
            userIds: self.userIds,
            title: self.title,
            subtitle: self.subtitle,
            body: self.body
        )
    }
}
