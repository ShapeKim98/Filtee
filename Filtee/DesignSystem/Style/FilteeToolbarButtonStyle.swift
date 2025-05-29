//
//  FilteeToolbarButtonStyle.swift
//  Filtee
//
//  Created by 김도형 on 5/28/25.
//

import SwiftUI

struct FilteeToolbarButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .aspectRatio(contentMode: .fit)
            .foregroundStyle(.gray75)
            .frame(width: 32, height: 32)
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .animation(.filteeDefault, value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == FilteeToolbarButtonStyle {
    static var filteeToolbar: Self {
        FilteeToolbarButtonStyle()
    }
}
