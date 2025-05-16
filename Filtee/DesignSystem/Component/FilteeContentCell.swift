//
//  FilteeContentCell.swift
//  Filtee
//
//  Created by 김도형 on 5/14/25.
//

import SwiftUI

struct FilteeContentCell<Content: View>: View {
    private let title: String
    private let subtitle: String
    private let content: Content
    
    init(
        title: String,
        subtitle: String,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            header
            
            content
                .frame(maxWidth: .infinity)
                .background(.deepTurquoise)
        }
        .clipRectangle(15)
        .roundedRectangleStroke(
            radius: 15,
            color: .deepTurquoise,
            lineWidth: 2
        )
    }
    
    private var header: some View {
        HStack {
            Text(title)
            
            Spacer()
            
            Text(subtitle)
        }
        .font(.pretendard(.caption1(.semiBold)))
        .foregroundStyle(.deepTurquoise)
        .padding(.horizontal, 12)
        .frame(height: 28)
    }
}

#Preview {
    FilteeContentCell(
        title: "Apple iPhone 16 Pro",
        subtitle: "EXIF"
    ) {
        Text("1234")
            .frame(height: 50)
    }
}
