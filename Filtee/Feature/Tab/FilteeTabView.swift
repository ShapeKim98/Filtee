//
//  TabView.swift
//  Filtee
//
//  Created by 김도형 on 5/19/25.
//

import SwiftUI

struct FilteeTabView: View {
    @Environment(\.firebaseManager)
    private var firebaseManager
    @Environment(\.userClient.deviceToken)
    private var userClientDeviceToken
    @Environment(\.notificationManager)
    private var notificationManager
    
    @StateObject
    private var tabRouter = FlowRouter<TabItem>(flow: .main)
    @StateObject
    private var toastRouter = ToastRouter()
    @StateObject
    private var mainNavigation = NavigationRouter<MainPath>()
    @StateObject
    private var makeNavigation = NavigationRouter<MakePath>()
    @StateObject
    private var searchNavigation = NavigationRouter<SearchPath>()
    
    @Namespace
    private var namespaceId: Namespace.ID
    
    @State
    private var showTabBar = true
    
    var body: some View {
        TabView(selection: $tabRouter.flow) {
            MainNavigationView()
                .environmentObject(mainNavigation)
                .environmentObject(toastRouter)
                .systemTabBarHidden()
                .tag(TabItem.main)
            
            MakeNavigationView()
                .environmentObject(makeNavigation)
                .systemTabBarHidden()
                .tag(TabItem.make)
            
            SearchNavigationView()
                .environmentObject(searchNavigation)
                .systemTabBarHidden()
                .tag(TabItem.search)
        }
        .overlay(alignment: .bottom) {
            if showTabBar {
                tabBar
                    .disabled(!showTabBar)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .overlay(alignment: .top) {
            ZStack {
                ForEach(toastRouter.messageQueue, id: \.self) { message in
                    toastMessage(message)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        }
        .ignoresSafeArea(.keyboard, edges: .all)
        .task(bodyTask)
        .onChange(
            of: makeNavigation.path,
            perform: makePathOnChange
        )
        .onChange(
            of: mainNavigation.path,
            perform: mainPathOnChange
        )
        .onChange(
            of: searchNavigation.path,
            perform: searchPathOnChange
        )
    }
}

// MARK: - Configure Views
private extension FilteeTabView {
    var tabBar: some View {
        HStack(spacing: 32) {
            Spacer()
            
            ForEach(TabItem.allCases, id: \.self) { tab in
                tabItem(tab)
            }
            
            Spacer()
        }
        .frame(height: 68)
        .background {
            VisualEffect(style: .systemUltraThinMaterial)
        }
        .clipRectangle(9999)
        .roundedRectangleStroke(
            radius: 9999,
            color: .secondary.opacity(0.6)
        )
        .padding(.horizontal, 20)
        .animation(.filteeSpring, value: tabRouter.flow)
    }
    
    @ViewBuilder
    func tabItem(_ tab: TabItem) -> some View {
        let isSelected = tabRouter.flow == tab
        
        Button(action: { tabRouter.switch(tab) }) {
            VStack {
                Spacer()
                
                Image(tab.image(isSelected))
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(isSelected ? .gray15 : .secondary)
                    .frame(width: 32, height: 32)
                
                Spacer()
            }
            .if(isSelected) { $0.background(alignment: .top) {
                Rectangle().fill(.gray15)
                    .frame(height: 4)
                    .cornerRadius(
                        radius: 2,
                        corners: [.bottomLeft, .bottomRight]
                    )
                    .matchedGeometryEffect(id: "isSelected", in: namespaceId)
            }}
        }
    }
    
    func toastMessage(_ message: String) -> some View {
        Text(message)
            .font(.pretendard(.body2(.bold)))
            .foregroundStyle(.gray45)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(.ultraThinMaterial)
            .clipRectangle(9999)
    }
}

// MARK: - Functions
private extension FilteeTabView {
    @Sendable
    func bodyTask() async {
        do {
//            let token = try await firebaseManager.fetchFCMToken()
//            try await userClientDeviceToken(token)
            for try await payload in await notificationManager.payloadStream() {
                print(payload)
            }
        } catch {
            print(error)
        }
    }
    
    func makePathOnChange(_ newValue: [MakePath]) {
        withAnimation(.filteeSpring) {
            if case .edit = newValue.last {
                showTabBar = false
            } else {
                showTabBar = true
            }
        }
    }
    
    func mainPathOnChange(_ newValue: [MainPath]) {
        withAnimation(.filteeSpring) {
            switch newValue.last {
            case .chat, .detail, .bannerWeb:
                showTabBar = false
            default:
                showTabBar = true
            }
        }
    }
    
    func searchPathOnChange(_ newValue: [SearchPath]) {
        withAnimation(.filteeSpring) {
            switch newValue.last {
            case .chat, .userDetail, .detail:
                showTabBar = false
            default:
                showTabBar = true
            }
        }
    }
}

#Preview {
    FilteeTabView()
}
