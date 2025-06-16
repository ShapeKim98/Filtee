//
//  RootRouter.swift
//  Filtee
//
//  Created by 김도형 on 5/19/25.
//

import Foundation

@MainActor
final class FlowRouter<T>: ObservableObject {
    @Published
    var flow: T
    
    init(flow: T) {
        self.flow = flow
    }
    
    func `switch`(_ flow: T) {
        self.flow = flow
    }
}
