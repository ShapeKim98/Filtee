//
//  MainView.swift
//  Filtee
//
//  Created by 김도형 on 5/21/25.
//

import SwiftUI

import NukeUI

struct MainView: View {
    @Environment(\.userClient.todayAuthor)
    private var userClientTodayAuthor
    @Environment(\.filterClient.hotTrend)
    private var filterClientHotTrend
    @Environment(\.filterClient.todayFilter)
    private var filterClientTodayFilter
    
    @State
    private var todayFilter: TodayFilterModel?
    @State
    private var hotTrends: [FilterModel] = []
    @State
    private var scrollOffset: CGFloat = 0
    
    var body: some View {
        ScrollView(content: content)
            .coordinateSpace(name: "ScrollView")
            .background {
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
            .ifLet(todayFilter?.filtered) { view, value in
                view.background {
                    backgroundImage(url: value)
                }
            }
            .task(bodyTask)
    }
}

// MARK: - Configure Views
private extension MainView {
    func content() -> some View {
        VStack(spacing: 0) {
            todayFilterSection
            
            hotTrendSection
            
            Spacer()
        }
        .scrollOffset($scrollOffset, coordinateSpace: "ScrollView")
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
            
            Button {
                
            } label: {
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
        VStack {
            LazyImage(url: URL(string: url)) { state in
                lazyImageTransform(state) { image in
                    image.aspectRatio(contentMode: .fill)
                        .frame(height: 500)
                }
            }
            .filteeDim()
            
            Spacer()
        }
        .ignoresSafeArea(edges: .top)
    }
    
    @ViewBuilder
    var hotTrendSection: some View {
        VStack(spacing: 0) {
            FilteeTitle("핫 트렌드")
            
            HotTrendList(filters: hotTrends) { filter in
                hotTrendCell(filter)
            }
            .frame(height: 240)
        }
    }
    
    @ViewBuilder
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
}

// MARK: - Fuctions
private extension MainView {
    @Sendable
    func bodyTask() async {
        do {
            async let todayFilter = filterClientTodayFilter()
            async let hotTrends = filterClientHotTrend()
            self.todayFilter = try await todayFilter
            self.hotTrends = try await hotTrends
        } catch {
            print(error)
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
