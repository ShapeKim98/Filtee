//
//  ContentView.swift
//  Filtee
//
//  Created by 김도형 on 5/11/25.
//

import SwiftUI

struct RootView: View {
    @Environment(\.rootRouter)
    private var rootRouter
    
    @State
    private var flow: Root = .splash
    
    var body: some View {
        VStack {
            switch flow {
            case .login:
                LoginView()
            case .splash:
                SplashView()
            case .tab:
                FilteeTabView()
            }
        }
        .animation(.smooth, value: flow)
        .task(bodyTask)
    }
}

// MARK: - Functions
private extension RootView {
    @Sendable
    func bodyTask() async {
        for await flow in rootRouter.stream {
            self.flow = flow
        }
    }
}

#if DEBUG
#Preview {
    RootView()
        .environment(\.authClient, .testValue)
        .environment(\.userClient, .testValue)
        .environment(\.filterClient, .testValue)
}
#endif
