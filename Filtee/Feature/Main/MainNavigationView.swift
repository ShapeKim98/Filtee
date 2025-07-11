//
//  MainNavigationView.swift
//  Filtee
//
//  Created by 김도형 on 5/28/25.
//

import SwiftUI

struct MainNavigationView: View {
    @EnvironmentObject
    private var navigation: NavigationRouter<MainPath>
    
    var body: some View {
        NavigationStack(path: $navigation.path) {
            MainView()
                .environmentObject(navigation)
                .navigationDestination(for: MainPath.self) { path in
                    switch path {
                    case let .detail(id):
                        FilterDetailView<MainPath>(filterId: id)
                            .environmentObject(navigation)
                    case let .chat(opponentId):
                        ChatView<MainPath>(opponentId: opponentId)
                            .environmentObject(navigation)
                    case let .userDetail(user):
                        UserDetailView<MainPath>(user: user)
                            .environmentObject(navigation)
                    }
                }
        }
    }
}
