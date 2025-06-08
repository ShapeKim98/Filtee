//
//  RootRouter.swift
//  Filtee
//
//  Created by 김도형 on 5/19/25.
//

import Foundation


final class FlowRouter<T: Sendable>: Sendable {
    @MainActor
    private var continuation: AsyncStream<T>.Continuation?
    
    func `switch`(_ flow: T) async {
        await continuation?.yield(flow)
    }
    
    @MainActor
    var stream: AsyncStream<T> {
        return AsyncStream { [weak self] continuation in
            self?.continuation = continuation
        }
    }
}
