//
//  SearchNavigationView.swift
//  Filtee
//
//  Created by 김도형 on 7/10/25.
//

import SwiftUI

struct SearchNavigationView: View {
    @EnvironmentObject
    private var navigation: NavigationRouter<SearchPath>
    
    var body: some View {
        NavigationStack(path: $navigation.path) {
            SearchView()
                .environmentObject(navigation)
                .navigationDestination(for: SearchPath.self) { path in
                    switch path {
                    case let .userDetail(user):
                        UserDetailView<SearchPath>(user: user)
                            .environmentObject(navigation)
                    case let .chat(opponentId):
                        ChatView<SearchPath>(opponentId: opponentId)
                            .environmentObject(navigation)
                    }
                }
        }
    }
}

#Preview {
    SearchNavigationView()
}
