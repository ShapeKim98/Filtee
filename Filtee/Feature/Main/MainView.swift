//
//  MainView.swift
//  Filtee
//
//  Created by 김도형 on 5/21/25.
//

import SwiftUI

struct MainView: View {
    @Environment(\.userClient.todayAuthor)
    private var userClientTodayAuthor
    @Environment(\.filterClient.hotTrend)
    private var filterClientHotTrend
    @Environment(\.filterClient.todayFilter)
    private var filterClientTodayFilter
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#if DEBUG
#Preview {
    MainView()
        .environment(\.userClient, .testValue)
        .environment(\.filterClient, .testValue)
}
#endif
