//
//  WebSocketManager.swift
//  Filtee
//
//  Created by 김도형 on 7/4/25.
//

import Foundation
import Combine
import SocketIO

actor WebSocketManager<Message: ResponseDTO> {
    private var manager: SocketManager?
    private var socket: SocketIOClient?
    private var isConnected = false
    
    nonisolated(unsafe)
    private var queue = [Message]()
    nonisolated(unsafe)
    private var continuation: AsyncThrowingStream<Message, Error>.Continuation?
    
    func connect<E: Endpoint>(_ endPoint: E, event: String) async throws {
        let request = try endPoint.asURLRequest()
        
        guard let url = URL(string: endPoint.baseURL) else {
            throw NSError(
                domain: "WebSocketManager",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]
            )
        }
        // Socket.IO Manager 생성
        let manager = SocketManager(socketURL: url, config: [
            .log(true),
            .extraHeaders(request.headers.dictionary),
            .forceWebsockets(true)
        ])
        self.manager = manager
        socket = manager.socket(forNamespace: endPoint.path)
        // 연결 시작 및 대기
        
        try addHandlers(event)
        
        isConnected = true
    }
    
    func stream() -> AsyncThrowingStream<Message, Error> {
        return AsyncThrowingStream { [weak self] continuation in
            self?.queue.forEach { continuation.yield($0) }
            self?.queue.removeAll()
            self?.continuation = continuation
        }
    }
    
    func disconnect() async {
        // 1. 모든 이벤트 핸들러 제거
        socket?.removeAllHandlers()
        
        // 2. 소켓 연결 해제
        socket?.disconnect()
        
        // 3. Manager도 해제
        manager?.disconnect()
        
        // 4. 참조 해제
        socket = nil
        manager = nil
        isConnected = false
        continuation?.finish()
        continuation = nil
    }
    
    func getConnectionStatus() -> Bool {
        return isConnected
    }
    
    private func addHandlers(_ event: String) throws {
        guard let socket else {
            throw NSError(
                domain: "WebSocketManager",
                code: -7,
                userInfo: [NSLocalizedDescriptionKey: "Socket not initialized"]
            )
        }
        
        socket.on(event) { [weak self] data, _ in
            print("🎯 '\(event)' 이벤트 수신!")
            print("📦 받은 데이터: \(data)")
            print("📊 데이터 타입: \(type(of: data))")
            do {
                guard let jsonData = try self?.convertToJSONData(data) else {
                    throw NSError(
                        domain: "WebSocketManager",
                        code: -3,
                        userInfo: [NSLocalizedDescriptionKey: "Invalid data format"]
                    )
                }
                let decodedMessage = try JSONDecoder().decode(Message.self, from: jsonData)
                
                if self?.continuation == nil {
                    self?.queue.append(decodedMessage)
                } else {
                    self?.continuation?.yield(decodedMessage)
                }
            } catch {
                self?.continuation?.finish(throwing: error)
            }
        }
        
        // 연결 성공 이벤트
        socket.on(clientEvent: .connect) { data, ack in
            print("✅ 연결 성공 확인")
        }
        
        // 연결 해제 시
        socket.on(clientEvent: .disconnect) { data, ack in
            print("⚠️ Socket disconnected")
        }
        
        socket.on(clientEvent: .error) { [weak self] _, _ in
            let error = NSError(
                domain: "SocketIO",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Connection failed"]
            )
            self?.continuation?.finish(throwing: error)
        }
        
        socket.onAny { event in
            let eventName = event.event
            let eventData = event.items
            
            print("🎯 '이벤트: \(eventName)' 수신!")
            print("📦 데이터: \(eventData ?? [])")
            print("📊 데이터 타입: \(type(of: eventData))")
        }
        
        socket.connect()
    }
    
    nonisolated(unsafe)
    private func convertToJSONData(_ data: [Any]) throws -> Data {
        guard !data.isEmpty else {
            throw NSError(
                domain: "WebSocketManager",
                code: -4,
                userInfo: [NSLocalizedDescriptionKey: "Empty data"]
            )
        }
        
        let firstItem = data[0]
        
        // Data 타입인 경우
        if let jsonData = firstItem as? Data {
            return jsonData
        }
        
        // String 타입인 경우
        if let jsonString = firstItem as? String {
            guard let stringData = jsonString.data(using: .utf8) else {
                throw NSError(
                    domain: "WebSocketManager",
                    code: -5,
                    userInfo: [NSLocalizedDescriptionKey: "Invalid JSON string"]
                )
            }
            return stringData
        }
        
        // Dictionary나 Array인 경우
        if JSONSerialization.isValidJSONObject(firstItem) {
            return try JSONSerialization.data(withJSONObject: firstItem)
        }
        
        // 전체 배열을 JSON으로 변환
        return try JSONSerialization.data(withJSONObject: data)
    }
}
