//
//  FilteeTag.swift
//  Filtee
//
//  Created by 김도형 on 5/14/25.
//

import SwiftUI

struct FilteeTag: View {
    private let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        Text(text)
            .font(.pretendard(.caption1(.medium)))
            .foregroundStyle(.gray60)
            .padding(.horizontal, 9)
            .frame(height: 24)
            .background(.blackTurquoise)
            .clipRectangle(9999)
    }
}

#Preview {
    FilteeTag("#카테고리")
}
