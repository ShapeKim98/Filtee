//
//  FTFontModifier.swift
//  Filtee
//
//  Created by 김도형 on 5/11/25.
//

import SwiftUI

private struct TFFontModifier<F: TFFontConvertible>: ViewModifier {
    private let font: F
    
    init(_ font: F) {
        self.font = font
    }
    
    func body(content: Content) -> some View {
        let uiFont = font.uiFont
        let lineSpacing = font.height - (uiFont?.lineHeight ?? 0)
        
        content
            .font(font.font)
            .lineSpacing(lineSpacing)
            .kerning(font.kerning)
            .padding(.vertical, lineSpacing / 2)
    }
}

extension View {
    @ViewBuilder
    func font(_ font: TFFont) -> some View {
        switch font {
        case .pretendard(let pretendard):
            modifier(TFFontModifier(pretendard))
        case .mulgyeol(let mulgyeol):
            modifier(TFFontModifier(mulgyeol))
        }
    }
}

#Preview {
    ScrollView {
        VStack(alignment: .leading) {
            Text("새싹아 일어나 어서 일어나서 코딩 해야지")
                .font(.pretendard(.title()))
            
            Text("새싹아 일어나 어서 일어나서 코딩 해야지")
                .font(.pretendard(.body1()))
            
            Text("새싹아 일어나 어서 일어나서 코딩 해야지")
                .font(.pretendard(.body2()))
            
            Text("새싹아 일어나 어서 일어나서 코딩 해야지")
                .font(.pretendard(.body3()))
            
            Text("새싹아 일어나 어서 일어나서 코딩 해야지")
                .font(.pretendard(.caption1()))
            
            Text("새싹아 일어나 어서 일어나서 코딩 해야지")
                .font(.pretendard(.caption2()))
            
            Text("새싹아 일어나 어서 일어나서 코딩 해야지")
                .font(.pretendard(.caption3()))
            
            Text("새싹을 담은 필터")
                .font(.mulgyeol(.title1))
            
            Text("새싹을 담은 필터")
                .font(.mulgyeol(.body1))
            
            Text("새싹을 담은 필터")
                .font(.mulgyeol(.caption1))
        }
    }
}
