//
//  PushRequestDTO.swift
//  Filtee
//
//  Created by 김도형 on 7/23/25.
//

import Foundation

struct PushRequest: RequestDTO {
    let userIds: [String]
    let title: String
    let subtitle: String?
    let body: String
    
    enum CodingKeys: String, CodingKey {
        case userIds = "user_ids"
        case title
        case subtitle
        case body
    }
}
