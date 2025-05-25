//
//  FilteeTitle.swift
//  Filtee
//
//  Created by 김도형 on 5/13/25.
//

import SwiftUI

struct FilteeTitle<SubButton: View>: View {
    private let title: String
    private let subButton: SubButton
    
    init(
        _ title: String,
        subButton: @escaping () -> SubButton = { EmptyView() }
    ) {
        self.title = title
        self.subButton = subButton()
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(.pretendard(.body1(.bold)))
                .foregroundStyle(.gray60)
            
            Spacer()
            
            subButton
                .font(.pretendard(.body1(.medium)))
                .foregroundStyle(.gray75)
        }
        .padding(.horizontal, 20)
        .frame(height: 48)
    }
}

#Preview {
    FilteeTitle("Main Title")
    
    FilteeTitle("Main Title") {
        Button("Sub Button", action: {})
    }
}
