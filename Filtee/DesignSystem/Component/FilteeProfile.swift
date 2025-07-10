//
//  FilteeProfile.swift
//  Filtee
//
//  Created by 김도형 on 5/24/25.
//

import SwiftUI

import NukeUI

struct FilteeProfile: View {
    private let profile: ProfileModel
    private let filters: [FilterModel]?
    private let showInformation: Bool
    private let cellAction: ((FilterModel) -> Void)?
    private let chatButtonAction: (() -> Void)?
    
    init(
        profile: ProfileModel,
        filters: [FilterModel]? = nil,
        showInformation: Bool = true,
        cellAction: ((FilterModel) -> Void)? = nil,
        chatButtonAction: (() -> Void)? = nil
    ) {
        self.profile = profile
        self.filters = filters
        self.showInformation = showInformation
        self.cellAction = cellAction
        self.chatButtonAction = chatButtonAction
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            profileSection
                .padding(.horizontal, 20)
            
            filterImagesSection
            
            if showInformation {
                hashTagSection
                
                introductionSection
                    .padding(.horizontal, 20)
            }
        }
    }
}

// MARK: Configure Views
private extension FilteeProfile {
    var profileSection: some View {
        HStack(spacing: 12) {
            LazyImage(url: URL(string: profile.profileImage ?? "")) { state in
                lazyImageTransform(state) { image in
                    image.aspectRatio(contentMode: .fill)
                }
            }
            .frame(width: 72, height: 72)
            .clipRectangle(9999)
            .clipped()
            .roundedRectangleStroke(
                radius: 9999,
                color: .gray75.opacity(0.5)
            )
            
            VStack(alignment: .leading, spacing: 8) {
                Text(profile.nick)
                    .font(.mulgyeol(.body1))
                    .foregroundStyle(.gray30)
                
                if let name = profile.name {
                    Text(name)
                        .font(.pretendard(.body1(.medium)))
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            if let chatButtonAction {
                Button(action: chatButtonAction) {
                    Image(.message)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(.gray30)
                        .frame(width: 32, height: 32)
                        .padding(6)
                        .background(.deepTurquoise)
                        .clipRectangle(8)
                }
            }
        }
    }
    
    @ViewBuilder
    var filterImagesSection: some View {
        if let filters {
            FilterList(filters: filters) { filter in
                Button(action: { cellAction?(filter) }) {
                    LazyImage(url: URL(string: filter.filtered ?? "")) { state in
                        lazyImageTransform(state) { image in
                            image.aspectRatio(contentMode: .fill)
                        }
                    }
                    .frame(width: 120, height: 80)
                    .clipRectangle(4)
                    .clipped()
                }
                .disabled(cellAction == nil)
            }
            .frame(height: 80)
        }
    }
    
    var hashTagSection: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 4) {
                ForEach(profile.hashTags, id: \.self) { hashTag in
                    FilteeTag(hashTag)
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    var introductionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let introduction = profile.introduction {
                Text(introduction)
                    .font(.mulgyeol(.caption1))
                    .foregroundStyle(.gray30)
            }
            
            if let description = profile.description {
                Text(description)
                    .font(.pretendard(.caption1(.regular)))
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private extension FilteeProfile {
    struct FilterList<Cell: View>: UIViewRepresentable {
        typealias DataSource = UICollectionViewDiffableDataSource<String, FilterModel>
        typealias Snapshot = NSDiffableDataSourceSnapshot<String, FilterModel>
        typealias Registration = UICollectionView.CellRegistration<UICollectionViewListCell, FilterModel>
        
        private let filters: [FilterModel]
        private let cell: (FilterModel) -> Cell
        
        init(filters: [FilterModel], cell: @escaping (FilterModel) -> Cell) {
            self.filters = filters
            self.cell = cell
        }
        
        func makeUIView(context: Context) -> UICollectionView {
            let collectionView = UICollectionView(
                frame: .zero,
                collectionViewLayout: configureCompositionalLayout()
            )
            collectionView.backgroundColor = .clear
            configureDataSource(collectionView, coordinator: context.coordinator)
            applySnapshot(coordinator: context.coordinator)
            return collectionView
        }
        
        func updateUIView(_ uiView: UICollectionView, context: Context) {
            applySnapshot(coordinator: context.coordinator)
        }
        
        func makeCoordinator() -> Coordinator {
            return Coordinator()
        }
    }
}

// MARK: - Configure Views
private extension FilteeProfile.FilterList {
    func configureDataSource(
        _ collectionView: UICollectionView,
        coordinator: Coordinator
    ) {
        let registration = Registration { cell, _, filter in
            cell.contentConfiguration = UIHostingConfiguration {
                self.cell(filter)
            }
        }
        
        coordinator.dataSource = DataSource(
            collectionView: collectionView
        ) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(
                using: registration,
                for: indexPath,
                item: item
            )
        }
    }
    
    func configureCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { _, _ in
            self.configureSectionLayout()
        }
        return layout
    }
    
    func configureSectionLayout() -> NSCollectionLayoutSection {
        let itemSize: NSCollectionLayoutSize
        let groupSize: NSCollectionLayoutSize
        itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(120),
            heightDimension: .absolute(80)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 12
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 20,
            bottom: 0,
            trailing: 20
        )
        section.orthogonalScrollingBehavior = .groupPaging
        
        return section
    }
    
    func applySnapshot(coordinator: Coordinator) {
        var snapshot = Snapshot()
        snapshot.appendSections(["ProfileFilterImages"])
        snapshot.appendItems(filters, toSection: "ProfileFilterImages")
        coordinator.dataSource?.apply(snapshot, animatingDifferences: false)
    }
}

// MARK: - Coordinator
private extension FilteeProfile.FilterList {
    final class Coordinator {
        var dataSource: DataSource?
    }
}

#if DEBUG
#Preview {
    FilteeProfile(
        profile: UserInfoResponseDTO.todayAuthorMock.toModel(),
        filters: FilterSummaryResponseDTO.hotTrendMock.map { $0.toModel() },
        chatButtonAction: { }
    )
    .fixedSize()
    .filteeBackground()
    .ignoresSafeArea()
}
#endif
