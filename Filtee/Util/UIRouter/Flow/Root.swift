//
//  Root.swift
//  Filtee
//
//  Created by 김도형 on 5/19/25.
//

import SwiftUICore

enum Root: Sendable {
    case tab
    case login
    case splash
}

extension FlowRouter: EnvironmentKey where T == Root {
    static let defaultValue: FlowRouter<Root> = FlowRouter()
}

extension EnvironmentValues {
    var rootRouter: FlowRouter<Root> {
        get { self[FlowRouter<Root>.self] }
        set { self[FlowRouter<Root>.self] = newValue }
    }
}
