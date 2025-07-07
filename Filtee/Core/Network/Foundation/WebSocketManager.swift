//
//  WebSocketManager.swift
//  Filtee
//
//  Created by 김도형 on 7/4/25.
//

import Foundation

import Alamofire

actor WebSocketManager<Message: ResponseDTO> {
    private var webSocketTask: URLSessionWebSocketTask?
    private var isConnected = false
    nonisolated(unsafe)
    private var continuation: AsyncThrowingStream<Message, Error>.Continuation?
    
    func connect<E: Endpoint>(_ endPoint: E) async throws {
        let request = try endPoint.asURLRequest()
        webSocketTask = defaultSession.session.webSocketTask(with: request)
        webSocketTask?.resume()
        isConnected = true
        
        try await receiveMessage()
    }
    
    func receiveStream() async throws -> AsyncThrowingStream<Message, Error> {
        return AsyncThrowingStream { [weak self] continuation in
            self?.continuation = continuation
        }
    }
    
    func receiveMessage() async throws {
        while let webSocketTask, isConnected {
            do {
                let message = try await webSocketTask.receive()
                guard case let .data(data) = message else { continue }
                let decodedMessage = try JSONDecoder().decode(Message.self, from: data)
                continuation?.yield(decodedMessage)
            } catch {
                continuation?.finish(throwing: error)
            }
        }
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        isConnected = false
    }
    
    func getConnectionStatus() -> Bool {
        return isConnected
    }
}
