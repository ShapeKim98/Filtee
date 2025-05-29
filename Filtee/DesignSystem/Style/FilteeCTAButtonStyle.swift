//
//  FilteeCTAButtonStyle.swift
//  Filtee
//
//  Created by 김도형 on 5/27/25.
//

import SwiftUI

struct FilteeCTAButtonStyle: ButtonStyle {
    @Environment(\.isEnabled)
    private var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        let color: Color = isEnabled
        ? .brightTurquoise
        : .gray90
        let textColor: Color = isEnabled ? .gray30 : .gray75
        
        configuration.label
            .font(.pretendard(.title(.bold)))
            .foregroundStyle(textColor)
            .frame(height: 46)
            .frame(maxWidth: .infinity)
            .background(color)
            .clipRectangle(8)
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .animation(.filteeDefault, value: configuration.isPressed)
            .animation(.filteeDefault, value: isEnabled)
    }
}

extension ButtonStyle where Self == FilteeCTAButtonStyle {
    static var filteeCTA: Self { FilteeCTAButtonStyle() }
}

#Preview {
    Button("결제하기") {
        
    }
    .buttonStyle(.filteeCTA)
    .disabled(false)
    
    Button("구매완료") {
        
    }
    .buttonStyle(.filteeCTA)
    .disabled(true)
}
