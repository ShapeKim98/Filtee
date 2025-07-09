//
//  ContentView.swift
//  Filtee
//
//  Created by 김도형 on 5/11/25.
//

import SwiftUI

struct RootView: View {
    @StateObject
    private var rootRouter = FlowRouter<Root>(flow: .splash)
    
    var body: some View {
        content
            .animation(.smooth, value: rootRouter.flow)
    }
    
    @ViewBuilder
    var content: some View {
        switch rootRouter.flow {
        case .login:
            LoginView()
                .environmentObject(rootRouter)
        case .splash:
            SplashView()
                .environmentObject(rootRouter)
        case .tab:
            FilteeTabView()
                .environmentObject(rootRouter)
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
