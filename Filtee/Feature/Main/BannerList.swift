//
//  BannerList.swift
//  Filtee
//
//  Created by 김도형 on 5/24/25.
//

import SwiftUI

struct BannerList<Cell: View>: UIViewRepresentable {
    typealias DataSource = UICollectionViewDiffableDataSource<String, BannerModel>
    typealias Snapshot = NSDiffableDataSourceSnapshot<String, BannerModel>
    typealias Registration = UICollectionView.CellRegistration<UICollectionViewCell, BannerModel>
    
    @Binding
    private var selection: BannerModel?
    private let banners: [BannerModel]
    private let cell: (BannerModel) -> Cell
    
    init(
        selection: Binding<BannerModel?>,
        banners: [BannerModel],
        cell: @escaping (BannerModel) -> Cell
    ) {
        self._selection = selection
        self.banners = banners
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
        guard
            let selection,
            let indexPath = context.coordinator.dataSource?.indexPath(for: selection)
        else { return }
        uiView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
}

// MARK: - Coordinator
extension BannerList {
    final class Coordinator {
        var dataSource: DataSource?
    }
}

// MARK: - Configure Views
private extension BannerList {
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
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(100)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item]
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.orthogonalScrollingBehavior = .groupPagingCentered
        
        section.visibleItemsInvalidationHandler = { items, offset, environment in
            let containerWidth = environment.container.contentSize.width
            
            let maxDistance = containerWidth / 2
            for item in items {
                let itemCenterX = item.center.x - offset.x
                let distanceFromCenter = abs(containerWidth / 2 - itemCenterX)
                let normalizedDistance = min(distanceFromCenter / maxDistance, 1.0)
                
                let minAlpha: CGFloat = 0.3
                let alpha = 1.0 - (normalizedDistance * (1.0 - minAlpha))
                
                guard !banners.isEmpty && alpha == 1 else { return }
                selection = banners[item.indexPath.item]
            }
        }
        
        return section
    }
    
    func applySnapshot(coordinator: Coordinator) {
        var snapshot = Snapshot()
        snapshot.appendSections(["BannerSection"])
        snapshot.appendItems(banners, toSection: "BannerSection")
        coordinator.dataSource?.apply(snapshot, animatingDifferences: false)
    }
}
