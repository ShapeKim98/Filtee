//
//  FTSelectButtonStyle.swift
//  Filtee
//
//  Created by 김도형 on 5/12/25.
//

import SwiftUI

struct FilteeSelectButtonStyle: ButtonStyle {
    private let isSelected: Bool
    
    init(isSelected: Bool) {
        self.isSelected = isSelected
    }
    
    func makeBody(configuration: Configuration) -> some View {
        let weight: Pretendard.Weight = isSelected ? .bold : .medium
        let textColor: Color = isSelected ? .gray45 : .gray75
        let backgroundColor: Color = isSelected
        ? .brightTurquoise
        : .blackTurquoise
        
        configuration.label
            .font(.pretendard(.body2(weight)))
            .foregroundStyle(textColor)
            .padding(.horizontal, 17)
            .frame(height: 28)
            .background(backgroundColor)
            .clipRectangle(9999)
            .roundedRectangleStroke(
                radius: 9999,
                color: .blackTurquoise
            )
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .animation(.filteeDefault, value: configuration.isPressed)
            .animation(.filteeDefault, value: isSelected)
    }
}

extension ButtonStyle where Self == FilteeSelectButtonStyle {
    static func filteeSelected(_ isSelected: Bool) -> Self {
        FilteeSelectButtonStyle(isSelected: isSelected)
    }
}

#Preview {
    VStack {
        Button("Selected") {
            
        }
        .buttonStyle(.filteeSelected(true))
        
        Button("UnSelected") {
            
        }
        .buttonStyle(.filteeSelected(false))
    }
}
