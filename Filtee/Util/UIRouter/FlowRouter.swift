//
//  RootRouter.swift
//  Filtee
//
//  Created by 김도형 on 5/19/25.
//

import Foundation

actor FlowRouter<T> {
    init(
        switch: @escaping (T) -> Void,
        publisher: @escaping () -> AsyncStream<T>,
        cancelBag: @escaping () -> Void
    ) {
        self.switch = `switch`
        self.publisher = publisher
        self.cancelBag = cancelBag
    }
    
    var `switch`: (T) -> Void
    var publisher: () -> AsyncStream<T> = {
        return AsyncStream { $0.finish() }
    }
    var cancelBag: () -> Void
}
