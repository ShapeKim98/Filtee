//
//  VisualEffectView.swift
//  Filtee
//
//  Created by 김도형 on 5/14/25.
//

import SwiftUI

struct BlurEffectView: UIViewRepresentable {
    private let style: UIBlurEffect.Style
    
    init(style: UIBlurEffect.Style) {
        self.style = style
    }
    
    func makeUIView(context: Context) -> some UIView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}
