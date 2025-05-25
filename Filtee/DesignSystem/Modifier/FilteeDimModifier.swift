//
//  FilteeDimModifier.swift
//  Filtee
//
//  Created by 김도형 on 5/16/25.
//

import SwiftUI

private struct FilteeDimModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.overlay {
            LinearGradient(
                stops: [
                    Gradient.Stop(
                        color: Color(red: 0.04, green: 0.04, blue: 0.04).opacity(0),
                        location: 0.00
                    ),
                    Gradient.Stop(
                        color: Color(red: 0.04, green: 0.04, blue: 0.04).opacity(0.8),
                        location: 1.00
                    ),
                ],
                startPoint: UnitPoint(x: 0.5, y: 0.25),
                endPoint: UnitPoint(x: 0.5, y: 0.95)
            )
        }
    }
}

extension View {
    func filteeDim() -> some View {
        modifier(FilteeDimModifier())
    }
}
