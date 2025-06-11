//
//  MakeNavigationView.swift
//  Filtee
//
//  Created by 김도형 on 6/11/25.
//

import SwiftUI

struct MakeNavigationView: View {
    @EnvironmentObject
    private var navigation: NavigationRouter<MakePath>
    
    var body: some View {
        NavigationStack(path: $navigation.path) {
            MakeView()
                .environmentObject(navigation)
                .navigationDestination(for: MakePath.self) { path in
                    switch path {
                    case let .edit(filteredImage, originalImage, filterValues):
                        EditView(
                            filteredImage: filteredImage,
                            originalImage: originalImage,
                            filterValues: filterValues
                        )
                        .environmentObject(navigation)
                    }
                }
        }
    }
}
