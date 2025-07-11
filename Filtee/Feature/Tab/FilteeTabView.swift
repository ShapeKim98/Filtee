//
//  TabView.swift
//  Filtee
//
//  Created by 김도형 on 5/19/25.
//

import SwiftUI

struct FilteeTabView: View {
    @StateObject
    private var tabRouter = FlowRouter<TabItem>(flow: .main)
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
        .ignoresSafeArea(.keyboard, edges: .all)
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
}

// MARK: - Functions
private extension FilteeTabView {
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
            case .chat, .detail:
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
