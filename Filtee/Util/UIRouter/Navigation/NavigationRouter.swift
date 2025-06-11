//
//  NavigationRouter.swift
//  Filtee
//
//  Created by 김도형 on 5/28/25.
//

import Foundation

@MainActor
final class NavigationRouter<P: Hashable & Sendable>: ObservableObject {
    @Published
    var path: [P] = []
    
    func push(_ path: P) {
        self.path.append(path)
    }
    
    func pop() {
        let _ = path.popLast()
    }
    
    func popAll() async {
        path.removeAll()
    }
}
