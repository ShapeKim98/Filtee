//
//  MainNavigationView.swift
//  Filtee
//
//  Created by 김도형 on 5/28/25.
//

import SwiftUI

struct MainNavigationView: View {
    @Environment(\.mainNavigation)
    private var navigation
    
    @State
    private var path: [MainPath] = []
    
    var body: some View {
        NavigationStack(path: $path) {
            MainView()
                .navigationDestination(for: MainPath.self) { path in
                    switch path {
                    case let .detail(id):
                        FilterDetailView(filterId: id)
                    }
                }
        }
        .task {
            for await action in navigation.stream {
                switch action {
                case let .push(path):
                    self.path.append(path)
                case .pop:
                    let _ = self.path.popLast()
                case .popAll:
                    self.path.removeAll()
                }
            }
        }
    }
}
