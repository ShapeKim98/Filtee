//
//  ChatClient.swift
//  Filtee
//
//  Created by 김도형 on 7/7/25.
//

import SwiftUICore

@preconcurrency import Combine

struct ChatClient {
    var createChats: @Sendable(
        _ id: String
    ) async throws -> RoomModel
    var chats: @Sendable(
        _ roomId: String,
        _ next: String
    ) async throws -> [ChatModel]
    var sendChats: @Sendable(
        _ roomId: String,
        _ content: String
    ) async throws -> Void
    var webSocketConnect: @Sendable(
        _ roomId: String
    ) async throws -> Void
    var webSocketDisconnect: @Sendable() async throws -> Void
    var webSocketStream: @Sendable() -> AsyncThrowingStream<ChatModel, Error>
}

extension ChatClient: EnvironmentKey, NetworkClientConfigurable {
    typealias E = ChatEndpoint
    
    static let defaultValue = {
        let webSocketManager = WebSocketManager<ChatResponseDTO>()
        
        return ChatClient(
            createChats: { id in
                let response: ChatRoomResponseDTO = try await request(.createChats(id))
                return response.toModel()
            },
            chats: { roomId, next in
                let requestModel = ChatsReqeust(roomId: roomId, next: next)
                let response: ListDTO<[ChatResponseDTO]> = try await request(.chats(requestModel))
                return response.data.map { $0.toModel() }
            },
            sendChats: { roomId, content in
                let requestModel = SendChatsRequest(roomId: roomId, content: content)
                try await request(.sendChats(requestModel))
            },
            webSocketConnect: { roomId in
                try await webSocketManager.connect(E.webSocket(roomId))
            },
            webSocketDisconnect: {
                await webSocketManager.disconnect()
            },
            webSocketStream: {
                return AsyncThrowingStream { continuation in
                    Task {
                        do {
                            for try await message in webSocketManager.stream() {
                                continuation.yield(message.toModel())
                            }
                        } catch {
                            continuation.finish(throwing: error)
                            await webSocketManager.disconnect()
                        }
                    }
                }
            }
        )
    }()
}

extension EnvironmentValues {
    var chatClient: ChatClient {
        get { self[ChatClient.self] }
        set { self[ChatClient.self] = newValue }
    }
}
