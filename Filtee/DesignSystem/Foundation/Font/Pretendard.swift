//
//  Pretendard.swift
//  Filtee
//
//  Created by 김도형 on 5/11/25.
//

import SwiftUI

enum Pretendard: FilteeFontConvertible {
    case title(Weight = .bold)
    case body1(Weight = .medium)
    case body2(Weight = .medium)
    case body3(Weight = .medium)
    case caption1(Weight = .regular)
    case caption2(Weight = .regular)
    case caption3(Weight = .regular)
    
    private var name: String {
        switch self {
        case .title(let weight),
             .body1(let weight),
             .body2(let weight),
             .body3(let weight),
             .caption1(let weight),
             .caption2(let weight),
             .caption3(let weight):
            return "Pretendard-\(weight.rawValue)"
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

extension Pretendard {
    enum Weight: String {
        case bold = "Bold"
        case semiBold = "SemiBold"
        case medium = "Medium"
        case regular = "Regular"
    }
}
