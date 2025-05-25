//
//  SplashView.swift
//  Filtee
//
//  Created by 김도형 on 5/19/25.
//

import SwiftUI

struct SplashView: View {
    @Environment(\.rootRouter)
    private var rootRouter
    @Environment(\.authClient.refresh)
    private var authClientRefresh
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Filtee")
                .font(.mulgyeol(.custom("B", 80)))
                .foregroundStyle(.gray15)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.brightTurquoise)
        .ignoresSafeArea()
        .task(bodyTask)
    }
}

// MARK: - Functions
private extension SplashView {
    @Sendable
    func bodyTask() async {
        do {
            try await authClientRefresh()
            await rootRouter.switch(.tab)
        } catch {
            await rootRouter.switch(.login)
        }
    }
}

#if DEBUG
#Preview {
    SplashView()
        .environment(\.authClient, .testValue)
}
#endif
