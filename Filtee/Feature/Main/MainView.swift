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
    
    var body: some View {
        ScrollView(content: content)
            .ifLet(todayFilter?.filtered) { view, value in
                view.background {
                    VStack {
                        LazyImage(url: URL(string: value)) { state in
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
            }
            .task(bodyTask)
    }
}

// MARK: - Configure Views
private extension MainView {
    func content() -> some View {
        VStack {
            todayFilterSection
            
            Spacer()
        }
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
            .background {
                VisualEffect(style: .systemChromeMaterial)
                    .mask(LinearGradient(
                        colors: [.clear, .black],
                        startPoint: UnitPoint(x: 0.5, y: 0.25),
                        endPoint: UnitPoint(x: 0.5, y: 0.95)
                    ))
            }
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
}

// MARK: - Fuctions
private extension MainView {
    @Sendable
    func bodyTask() async {
        do {
            todayFilter = try await filterClientTodayFilter()
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
