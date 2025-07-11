//
//  UserDetailView.swift
//  Filtee
//
//  Created by 김도형 on 7/10/25.
//

import SwiftUI

import NukeUI

struct UserDetailView<Path: Hashable & Sendable>: View {
    @EnvironmentObject
    private var navigation: NavigationRouter<Path>
    
    @Environment(\.filterClient.users)
    private var filterClientUsers
    
    @State
    private var filters = PaginationModel<FilterModel>()
    
    private let user: ProfileModel
    
    init(user: ProfileModel) {
        self.user = user
    }
    
    
    var body: some View {
        ScrollView(content: content)
            .filteeNavigation(
                title: user.nick,
                leadingItems: leadingItems,
                trailingItems: trailingItems
            )
            .background { bodyBackground }
            .task(bodyTask)
    }
}

// MARK: Configure Views
private extension UserDetailView {
    func content() -> some View {
        VStack(spacing: 16) {
            FilteeProfile(profile: user)
            
            filterList
        }
        .padding(.bottom, 68)
    }
    
    func leadingItems() -> some View {
        Button(action: backButtonAction) {
            Image(.chevron)
                .resizable()
        }
        .buttonStyle(.filteeToolbar)
    }
    
    func trailingItems() -> some View {
        Button(action: chatButtonAction) {
            Image(.message)
                .resizable()
        }
        .buttonStyle(.filteeToolbar)
    }
    
    func backgroundImage(_ url: String) -> some View {
        LazyImage(url: URL(string: url)) { state in
            lazyImageTransform(state) { image in
                image
                    .aspectRatio(contentMode: .fill)
                    .overlay(Color(red: 0.04, green: 0.04, blue: 0.04).opacity(0.8))
                    .clipped()
            }
        }
    }
    
    var bodyBackground: some View {
        VisualEffect(style: .systemChromeMaterialDark)
            .ifLet(user.profileImage) { view, url in
                view.background { backgroundImage(url) }
            }
            .ignoresSafeArea()
    }
    
    var filterList: some View {
        LazyVStack(spacing: 16) {
            ForEach(filters.data) { filter in
                let isLast = filters.data.last == filter
                
                Button(action: { filterListCellButtonAction(filter) }) {
                    filterListCell(filter)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .if(filters.nextCursor != "0" && isLast) { view in
                    VStack(spacing: 20) {
                        view
                        
                        ProgressView()
                            .controlSize(.large)
                            .task(progressViewTask)
                    }
                }
            }
        }
    }
    
    func filterListCell(_ filter: FilterModel) -> some View {
        HStack(spacing: 20) {
            filterListCellImage(filter)
            
            filterListCellInformation(filter)
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    func filterListCellImage(_ filter: FilterModel) -> some View {
        LazyImage(url: URL(string: filter.filtered ?? "")) { state in
            lazyImageTransform(state) { image in
                image.aspectRatio(contentMode: .fill)
            }
        }
        .frame(width: 100, height: 120)
        .clipRectangle(8)
        .clipped()
        .overlay(alignment: .bottomTrailing) {
            Image(filter.isLike ? .likeFill : .likeEmpty)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 24, height: 24)
                .padding(8)
        }
    }
    
    func filterListCellInformation(_ filter: FilterModel) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Text(filter.title)
                    .font(.mulgyeol(.body1))
                    .foregroundStyle(.gray30)
                
                if let category = filter.category {
                    FilteeTag("#" + category)
                }
            }
            
            Text(filter.creator.nick)
                .font(.pretendard(.body1(.medium)))
                .foregroundStyle(.secondary)
            
            Text(filter.description)
                .font(.pretendard(.caption1(.regular)))
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
        }
    }
}

// MARK: Functions
private extension UserDetailView {
    @Sendable
    func bodyTask() async {
        await paginationFilters()
    }
    
    @Sendable
    func progressViewTask() async {
        await paginationFilters()
    }
    
    func chatButtonAction() {
        switch Path.self {
        case is SearchPath.Type:
            navigation.push(SearchPath.chat(opponentId: user.id))
        case is MainPath.Type:
            navigation.push(MainPath.chat(opponentId: user.id))
        default: return
        }
    }
    
    func backButtonAction() {
        navigation.pop()
    }
    
    func filterListCellButtonAction(_ filter: FilterModel) {
        switch Path.self {
        case is SearchPath.Type:
            navigation.push(SearchPath.detail(id: filter.id))
        case is MainPath.Type:
            navigation.push(MainPath.detail(id: filter.id))
        default: return
        }
    }
    
    func paginationFilters() async {
        do {
            let filterList = try await filterClientUsers(
                user.id,
                filters.nextCursor,
                10,
                nil
            )
            self.filters.data.append(contentsOf: filterList.data)
            self.filters.nextCursor = filterList.nextCursor
        } catch {
            print(error)
        }
    }
}

#Preview {
    UserDetailView<SearchPath>(user: UserInfoResponseDTO.detailMock.toProfileModel())
        .environment(\.filterClient, .testValue)
}
