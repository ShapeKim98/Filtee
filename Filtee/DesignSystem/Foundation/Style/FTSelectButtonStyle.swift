//
//  FTSelectButtonStyle.swift
//  Filtee
//
//  Created by 김도형 on 5/12/25.
//

import SwiftUI

private struct FTSelectButtonStyle: ButtonStyle {
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
            .overlay {
                RoundedRectangle(cornerRadius: 9999, style: .continuous)
                    .stroke(.deepTurquoise, lineWidth: 1)
            }
    }
}

extension ButtonStyle where Self == FTSelectButtonStyle {
    static func selected(_ isSelected: Bool) -> Self {
        FTSelectButtonStyle(isSelected: isSelected)
    }
}

#Preview {
    VStack {
        Button("Selected") {
            
        }
        .buttonStyle(.selected(true))
        
        Button("UnSelected") {
            
        }
        .buttonStyle(.selected(false))
    }
}
