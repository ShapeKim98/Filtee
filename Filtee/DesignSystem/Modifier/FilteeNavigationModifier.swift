//
//  FilteeNavigationModifier.swift
//  Filtee
//
//  Created by 김도형 on 5/27/25.
//

import SwiftUI

private struct FilteeNavigationModifier<LeadingItems: View, TrailingItems: View>: ViewModifier {
    private let title: String
    
    private let leadingToolbarItems: LeadingItems
    private let trailingToolbarItems: TrailingItems
    
    init(
        title: String,
        @ViewBuilder leadingToolbarItems: () -> LeadingItems,
        @ViewBuilder trailingToolbarItems: () -> TrailingItems
    ) {
        self.title = title
        self.leadingToolbarItems = leadingToolbarItems()
        self.trailingToolbarItems = trailingToolbarItems()
    }
    
    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            Text(title)
                .font(.mulgyeol(.body1))
                .lineLimit(1)
                .padding(.vertical, 18)
                .frame(maxWidth: .infinity)
                .overlay(alignment: .leading) {
                    HStack(spacing: 8) {
                        Group { leadingToolbarItems }
                            .padding(8)
                    }
                    .padding(.leading, 4)
                }
                .overlay(alignment: .trailing) {
                    HStack(spacing: 8) {
                        Group { trailingToolbarItems }
                            .padding(8)
                    }
                    .padding(.trailing, 4)
                }
            
            content
        }
        .systemNavigationBarHidden()
    }
}

extension View {
    func filteeNavigation<LeadingItems: View, TrailingItems: View>(
        title: String,
        @ViewBuilder leadingItems: () -> LeadingItems = { EmptyView() },
        @ViewBuilder trailingItems: () -> TrailingItems = { EmptyView() }
    ) -> some View {
        modifier(FilteeNavigationModifier(
            title: title,
            leadingToolbarItems: leadingItems,
            trailingToolbarItems: trailingItems
        ))
    }
}
