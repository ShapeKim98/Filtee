//
//  View+Extension.swift
//  Filtee
//
//  Created by 김도형 on 5/12/25.
//

import SwiftUI

extension View {
    @ViewBuilder func `if`<Content: View>(
        _ condition: Bool,
        transform: (Self) -> Content
    ) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    func clipRectangle(_ radius: CGFloat) -> some View {
        self.clipShape(RoundedRectangle(
            cornerRadius: radius,
            style: .continuous
        ))
    }
    
    func roundedRectangleStroke(
        radius: CGFloat,
        color: Color,
        lineWidth: CGFloat = 1
    ) -> some View {
        self.overlay {
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .stroke(color, lineWidth: lineWidth)
        }
    }
    
    func filteeBackground() -> some View {
        self.background {
            BlurEffectView(style: .systemChromeMaterial)
        }
    }
}
