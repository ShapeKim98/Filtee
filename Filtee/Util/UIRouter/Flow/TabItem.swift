//
//  Tab.swift
//  Filtee
//
//  Created by 김도형 on 6/11/25.
//

import SwiftUICore

enum TabItem: CaseIterable {
    case main
    case make
    
    func image(_ isSelected: Bool) -> ImageResource {
        switch self {
        case .main:
            return isSelected ? .homeFill : .homeEmpty
        case .make:
            return isSelected ? .filterFill : .filterEmpty
        }
    }
}
