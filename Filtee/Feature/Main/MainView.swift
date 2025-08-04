//
//  MainView.swift
//  Filtee
//
//  Created by 김도형 on 5/21/25.
//

import SwiftUI

import IdentifiedCollections
import NukeUI

struct MainView: View {
    @EnvironmentObject
    private var navigation: NavigationRouter<MainPath>
    
    @Environment(\.userClient.todayAuthor)
    private var userClientTodayAuthor
    @Environment(\.filterClient.hotTrend)
    private var filterClientHotTrend
    @Environment(\.filterClient.todayFilter)
    private var filterClientTodayFilter
    @Environment(\.bannerClient.bannersMain)
    private var bannerClientBannersMain
    
    @State
    private var todayFilter: TodayFilterModel?
    @State
    private var hotTrends: [FilterModel] = []
    @State
    private var todayAuthor: TodayAuthorModel?
    @State
    private var scrollOffset: CGFloat = 0
    @State
    private var isLoading: Bool = true
    @State
    private var currentBanner: BannerModel?
    @State
    private var banners: IdentifiedArrayOf<BannerModel> = []
    
    private let timer = Timer.publish(
        every: 5,
        on: .main,
        in: .default
    )
        
    
    var body: some View {
        ScrollView(content: content)
            .coordinateSpace(name: "ScrollView")
            .background { scrollViewBackground }
            .ifLet(todayFilter?.filtered) { view, value in
                view.background {
                    backgroundImage(url: value)
                }
            }
            .overlay(alignment: .top) {
                navigationBar
            }
            .task(bodyTask)
    }
}

// MARK: - Configure Views
private extension MainView {
    func content() -> some View {
        VStack(spacing: 20) {
            todayFilterSection
            
            bannerList
            
            hotTrendSection
            
            todayAuthorSection
            
            Spacer()
        }
        .padding(.bottom, 68)
        .scrollOffset(
            $scrollOffset,
            coordinateSpace: "ScrollView"
        )
    }
    
    var scrollViewBackground: some View {
        VisualEffect(style: .systemChromeMaterial)
            .mask(LinearGradient(
                colors: [
                    .black.opacity(scrollOffset / CGFloat(160)),
                    .black.opacity(scrollOffset / CGFloat(160) + CGFloat(0.1)),
                    .black,
                    .black,
                    .black
                ],
                startPoint: UnitPoint(x: 0.5, y: 0),
                endPoint: UnitPoint(x: 0.5, y: 1)
            ))
            .ignoresSafeArea()
    }
    
    @ViewBuilder
    var todayFilterSection: some View {
        if let filter = todayFilter {
            VStack(alignment: .leading, spacing: 20) {
                
                todyFilterButton(filter)
                    .padding(.bottom, 147)
                
                todayFilterTitle(filter)
                
                Text(filter.description)
                    .font(.pretendard(.caption1(.regular)))
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
        }
    }
    
    func todayFilterTitle(_ filter: TodayFilterModel) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("오늘의 필터 소개")
                .font(.pretendard(.body3(.medium)))
                .foregroundStyle(.gray60)
            
            Group {
                Text(filter.introduction)
                
                Text(filter.title)
            }
            .font(.mulgyeol(.title1))
            .foregroundStyle(.gray30)
        }
    }
    
    func todyFilterButton(_ filter: TodayFilterModel) -> some View {
        HStack {
            Spacer()
            
            Button(action: useButtonAction) {
                Text("사용해보기")
                    .font(.pretendard(.caption1(.medium)))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 10)
                    .frame(height: 28)
                    .background(.ultraThinMaterial)
                    .cornerRadius(8)
            }
            .buttonStyle(.plain)
        }
    }
    
    func backgroundImage(url: String) -> some View {
        LazyImage(url: URL(string: url)) { state in
            lazyImageTransform(state) { image in
                GeometryReader { proxy in
                    let global = proxy.frame(in: .global)
                    let width = global.width
                    let isMinus = scrollOffset < 0
                    
                    let topHeight = isMinus ? -scrollOffset + width : width
                    image.aspectRatio(contentMode: .fill)
                        .filteeDim()
                        .frame(width: width, height: topHeight)
                    
                    let bottomHeight = isMinus ? scrollOffset + width : width
                    image.aspectRatio(contentMode: .fill)
                        .overlay(Color(red: 0.04, green: 0.04, blue: 0.04).opacity(0.9))
                        .frame(width: width, height: bottomHeight)
                        .offset(y: topHeight)
                }
            }
        }
        .ignoresSafeArea()
    }
    
    var hotTrendSection: some View {
        VStack(spacing: 0) {
            FilteeTitle("핫 트렌드")
            
            HotTrendList(filters: hotTrends) { filter in
                Button {
                    hotTrendButtonAction(id: filter.id)
                } label: {
                    hotTrendCell(filter)
                }
            }
            .frame(height: 240)
        }
    }
    
    func hotTrendCell(_ filter: FilterModel) -> some View {
        LazyImage(url: URL(string: filter.filtered ?? "")) { state in
            lazyImageTransform(state) { image in
                image.aspectRatio(contentMode: .fill)
            }
        }
        .frame(width: 200, height: 240)
        .clipRectangle(8)
        .clipped()
        .overlay(alignment: .topLeading) {
            Text(filter.title)
                .font(.mulgyeol(.caption1))
                .foregroundStyle(.gray30)
                .padding(.top, 8)
                .padding(.leading, 12)
        }
        .overlay(alignment: .bottomTrailing) {
            HStack(spacing: 2) {
                Image(filter.isLike ? .likeFill : .likeEmpty)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 16, height: 16)
                
                Text("\(filter.likeCount)")
                    .font(.pretendard(.caption1(.semiBold)))
                    .contentTransition(.numericText())
            }
            .foregroundStyle(.gray30)
            .padding(.bottom, 8)
            .padding(.trailing, 10)
        }
    }
    
    var todayAuthorSection: some View {
        VStack(spacing: 8) {
            FilteeTitle("오늘의 작가")
            
            if let todayAuthor {
                Button(action: { profileButtonAction(todayAuthor.author) }) {
                    FilteeProfile(
                        profile: todayAuthor.author,
                        filters: todayAuthor.filters,
                        cellAction: profileCellAction,
                        chatButtonAction: { chatButtonAction(todayAuthor) }
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    var navigationBar: some View {
        VisualEffect(style: .systemChromeMaterial)
            .mask(LinearGradient(
                colors: [
                    .clear,
                    .black,
                    .black,
                    .black
                ],
                startPoint: UnitPoint(x: 0.5, y: 1),
                endPoint: UnitPoint(x: 0.5, y: 0)
            ))
            .frame(height: 80)
            .opacity(scrollOffset / CGFloat(160))
            .ignoresSafeArea()
    }
    
    var bannerList: some View {
        BannerList(
            selection: $currentBanner,
            banners: banners.elements
        ) { banner in
            bannerCell(banner)
        }
        .frame(height: 100)
        .padding(.horizontal, 20)
    }
    
    func bannerCell(_ item: BannerModel) -> some View {
        Button(action: bannerButtonAction) {
            LazyImage(url: URL(string: item.imageURL)) { state in
                lazyImageTransform(state) { image in
                    image.aspectRatio(contentMode: .fill)
                }
                .frame(height: 100)
                .frame(maxWidth: .infinity)
            }
            .clipRectangle(24)
            .clipped()
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Fuctions
private extension MainView {
    @Sendable
    func bodyTask() async {
        guard isLoading else { return }
        defer { isLoading = false }
        do {
            async let todayFilter = filterClientTodayFilter()
            async let hotTrends = filterClientHotTrend()
            async let todayAuthor = userClientTodayAuthor()
            async let banners = bannerClientBannersMain()
            self.todayFilter = try await todayFilter
            self.hotTrends = try await hotTrends
            self.todayAuthor = try await todayAuthor
            self.banners = try await banners
            currentBanner = self.banners.first
            await timerStream()
        } catch {
            print(error)
        }
    }
    
    func useButtonAction() {
        Task {
            guard let id = todayFilter?.id else { return }
            navigation.push(.detail(id: id))
        }
    }
    
    func bannerButtonAction() {
        navigation.push(.bannerWeb)
    }
    
    func hotTrendButtonAction(id: String) {
        navigation.push(.detail(id: id))
    }
    
    func profileCellAction(_ filter: FilterModel) {
        navigation.push(.detail(id: filter.id))
    }
    
    func chatButtonAction(_ author: TodayAuthorModel) {
        navigation.push(.chat(opponentId: author.author.id))
    }
    
    func profileButtonAction(_ author: ProfileModel) {
        navigation.push(.userDetail(user: author))
    }
    
    func timerStream() async {
        for await _ in timer.autoconnect().values {
            guard let currentBanner else { return }
            withAnimation(.easeInOut(duration: 10)) {
                let index = banners.index(id: currentBanner.id) ?? 0
                self.currentBanner = banners[(index + 1) % banners.count]
            }
        }
    }
}

#if DEBUG
#Preview {
    MainView()
        .environment(\.userClient, .testValue)
        .environment(\.filterClient, .testValue)
}
#endif
