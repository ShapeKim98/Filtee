//
//  Pretendard.swift
//  Filtee
//
//  Created by 김도형 on 5/11/25.
//

import SwiftUI

enum Pretendard: TFFontConvertible {
    case title
    case body1
    case body2
    case body3
    case caption1
    case caption2
    case caption3
    
    private var name: String {
        switch self {
        case .title: return "Pretendard-Bold"
        case .body1, .body2, .body3:
            return "Pretendard-Medium"
        case .caption1, .caption2, .caption3:
            return "Pretendard-Regular"
        }
    }
    
    private var size: CGFloat {
        switch self {
        case .title: return 20
        case .body1: return 16
        case .body2: return 14
        case .body3: return 13
        case .caption1: return 12
        case .caption2: return 10
        case .caption3: return 8
        }
    }
    
    var font: Font {
        return .custom(name, size: size)
    }
    
    var uiFont: UIFont? {
        return UIFont(name: name, size: size)
    }
    
    var height: CGFloat {
        switch self {
        case .title: return 26
        case .body1: return 21
        case .body2: return 18
        case .body3: return 17
        case .caption1: return 16
        case .caption2: return 13
        case .caption3: return 8
        }
    }
    
    var kerning: CGFloat {
        return -0.01
    }
}
