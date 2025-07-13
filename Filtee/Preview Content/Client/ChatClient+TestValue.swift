//
//  ChatClient+TestValue.swift
//  Filtee
//
//  Created by 김도형 on 7/11/25.
//

import Foundation

extension ChatClient {
    static let testValue = {
        return ChatClient(
            createChats: { id in
                return RoomModel(
                    id: "dev_team",
                    createdAt: .now,
                    updatedAt: .now,
                    participants: [],
                    lastChat: nil
                )
            },
            chats: { _, _ in return [] },
            sendChats: { _, _ in },
            webSocketConnect: { roomId in },
            webSocketDisconnect: { },
            webSocketStream: {
                return AsyncThrowingStream { continuation in
                    continuation.finish()
                }
            }
        )
    }()
}
