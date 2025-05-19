//
//  Root.swift
//  Filtee
//
//  Created by 김도형 on 5/19/25.
//

import SwiftUICore

enum Root {
    case home
    case login
    case splash
}

extension FlowRouter: EnvironmentKey where T == Root {
    static let defaultValue: FlowRouter<Root> = {
        var continuation: AsyncStream<T>.Continuation?
        
        return FlowRouter(
            switch: { continuation?.yield($0) },
            publisher: {
                AsyncStream { continuation = $0 }
            },
            cancelBag: { continuation?.finish() }
        )
    }()
}

extension EnvironmentValues {
    var rootRouter: FlowRouter<Root> {
        get { self[FlowRouter<Root>.self] }
        set { self[FlowRouter<Root>.self] = newValue }
    }
}
