//
//  NavigationRouter.swift
//  Filtee
//
//  Created by 김도형 on 5/28/25.
//

import Foundation

final class NavigationRouter<P: Hashable & Sendable>: Sendable {
    enum Action: Sendable {
        case push(path: P)
        case pop
        case popAll
    }
    
    @MainActor
    private var continuation: AsyncStream<Action>.Continuation?
    
    @MainActor
    var stream: AsyncStream<Action> {
        return AsyncStream { [weak self] continuation in
            Task { @Sendable in
                self?.continuation = continuation
            }
        }
    }
    
    func push(_ path: P) async {
        await continuation?.yield(.push(path: path))
    }
    
    func pop() async {
        await continuation?.yield(.pop)
    }
    
    func popAll() async {
        await continuation?.yield(.popAll)
    }
}
