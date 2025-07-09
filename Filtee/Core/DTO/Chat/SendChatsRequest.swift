//
//  SendChatsRequest.swift
//  Filtee
//
//  Created by 김도형 on 7/7/25.
//

import Foundation

struct SendChatsRequest: RequestDTO {
    let roomId: String
    let content: String
}
