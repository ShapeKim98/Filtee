//
//  TabView.swift
//  Filtee
//
//  Created by 김도형 on 5/19/25.
//

import SwiftUI

struct FilteeTabView: View {
    @Environment(\.rootRouter)
    private var rootRouter
    @Environment(\.userClient)
    private var userClient
    
    var body: some View {
        Button("로그아웃") {
            userClient.logout()
            Task {
                await rootRouter.switch(.login)
            }
        }
    }
}

#Preview {
    FilteeTabView()
}
