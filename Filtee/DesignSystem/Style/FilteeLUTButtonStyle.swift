//
//  FilteeLUTButtonStyle.swift
//  Filtee
//
//  Created by 김도형 on 5/14/25.
//

import SwiftUI

private struct FilteeLUTButtonStyle: ButtonStyle {
    private let resource: ImageResource
    private let isSelected: Bool
    
    init(resource: ImageResource, isSelected: Bool) {
        self.resource = resource
        self.isSelected = isSelected
    }
    
    func makeBody(configuration: Configuration) -> some View {
        let color: Color = isSelected ? .gray30 : .gray75
        
        VStack(spacing: 8) {
            Image(resource)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 32, height: 32)
            
            configuration.label
                .font(.pretendard(.caption2(.semiBold)))
        }
        .foregroundStyle(color)
        .scaleEffect(configuration.isPressed ? 0.9 : 1)
        .animation(.filteeDefault, value: configuration.isPressed)
        .animation(.filteeDefault, value: isSelected)
    }
}

extension ButtonStyle where Self == FilteeLUTButtonStyle {
    static func filteeLUT(_ resource: ImageResource, isSelected: Bool) -> Self {
        FilteeLUTButtonStyle(resource: resource, isSelected: isSelected)
    }
}

#Preview {
    HStack {
        Spacer()
        
        Button("SELECTED") {
            
        }
        .buttonStyle(.filteeLUT(.brightness, isSelected: true))
        
        Spacer()
        
        
        Button("UNSELECTED") {
            
        }
        .buttonStyle(.filteeLUT(.brightness, isSelected: false))
        
        Spacer()
    }
}
