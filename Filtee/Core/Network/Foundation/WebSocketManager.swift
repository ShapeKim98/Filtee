//
//  WebSocketManager.swift
//  Filtee
//
//  Created by 김도형 on 7/4/25.
//

import Foundation
import Combine

import Alamofire

actor WebSocketManager<Message: ResponseDTO> {
    private var webSocketTask: URLSessionWebSocketTask?
    private var isConnected = false
    nonisolated(unsafe)
    private var subject = CurrentValueSubject<Message?, Error>(nil)
    
    func connect<E: Endpoint>(_ endPoint: E) async throws {
        let request = try endPoint.asURLRequest()
        webSocketTask = defaultSession.session.webSocketTask(with: request)
        webSocketTask?.resume()
        isConnected = true
        
        try await receiveMessage()
    }
    
    func stream() -> AsyncThrowingPublisher<AnyPublisher<Message, Error>> {
        return subject.compactMap(\.self).eraseToAnyPublisher().values
    }
    
    func receiveMessage() async throws {
        while let webSocketTask, isConnected {
            do {
                let message = try await webSocketTask.receive()
                guard case let .data(data) = message else { continue }
                let decodedMessage = try JSONDecoder().decode(Message.self, from: data)
                subject.send(decodedMessage)
            } catch {
                subject.send(completion: .failure(error))
            }
        }
    }
    
    func disconnect() async {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        isConnected = false
        subject = CurrentValueSubject<Message?, Error>(nil)
    }
    
    func getConnectionStatus() -> Bool {
        return isConnected
    }
}
