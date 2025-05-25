//
//  FilteeScrollOffsetModifier.swift
//  Filtee
//
//  Created by 김도형 on 5/24/25.
//

import SwiftUI

private struct ScrollOffsetPreferenceKey: PreferenceKey {
    nonisolated(unsafe) static var defaultValue: CGFloat = .zero
    
    // 여기에 reduce 메서드 작성
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}

private struct FilteeScrollOffsetModifier: ViewModifier {
    @Binding
    private var offset: CGFloat
    
    private let coordinateSpace: String
    
    init(offset: Binding<CGFloat>, coordinateSpace: String) {
        self._offset = offset
        self.coordinateSpace = coordinateSpace
    }
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(
                            key: ScrollOffsetPreferenceKey.self,
                            value: -geometry.frame(in: .named(coordinateSpace)).minY
                        )
                }
            )
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { newOffset in
                offset = newOffset
            }
    }
}

extension View {
    func scrollOffset(
        _ offset: Binding<CGFloat>,
        coordinateSpace: String
    ) -> some View {
        modifier(FilteeScrollOffsetModifier(
            offset: offset,
            coordinateSpace: coordinateSpace
        ))
    }
}
