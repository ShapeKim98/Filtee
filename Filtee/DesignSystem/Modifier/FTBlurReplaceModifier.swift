//
//  FTBlurReplaceModifier.swift
//  Filtee
//
//  Created by 김도형 on 5/13/25.
//

import SwiftUI

private struct FTBlurReplaceModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content
                .transition(.blurReplace)
        } else {
            content
                .transition(.opacity)
        }
    }
}

extension View {
    func filteeBlurReplace() -> some View {
        modifier(FTBlurReplaceModifier())
    }
}
