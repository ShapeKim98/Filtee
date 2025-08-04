//
//  ToastRouter.swift
//  Filtee
//
//  Created by 김도형 on 7/24/25.
//

import SwiftUI

@MainActor
final class ToastRouter: ObservableObject {
    @Published
    var messageQueue: [String] = []
    
    private var task: [Task<Void, Never>] = []
    
    func present(_ message: String) {
        withAnimation(.filteeSpring) {
            messageQueue.append(message)
        }
        task.append(Task {
            try? await Task.sleep(for: .seconds(3))
            withAnimation(.filteeSpring) {
                let _ = messageQueue.removeFirst()
            }
        })
    }
}
