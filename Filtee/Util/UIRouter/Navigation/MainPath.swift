//
//  HomePath.swift
//  Filtee
//
//  Created by 김도형 on 5/28/25.
//

import SwiftUICore

enum MainPath: Hashable, Sendable {
    case detail(id: String)
}

extension NavigationRouter: EnvironmentKey where P == MainPath {
    static let defaultValue = NavigationRouter()
}

extension EnvironmentValues {
    var mainNavigation: NavigationRouter<MainPath> {
        get { self[NavigationRouter<MainPath>.self] }
        set { self[NavigationRouter<MainPath>.self] = newValue }
    }
}
