//
//  Mulgyeol.swift
//  Filtee
//
//  Created by 김도형 on 5/11/25.
//

import SwiftUI

enum Mulgyeol: FilteeFontConvertible {
    case title1
    case body1
    case caption1
    case custom(_ weight: String, _ size: CGFloat)
    
    private var name: String {
        switch self {
        case .title1, .body1:
            return "OTHakgyoansimMulgyeolB"
        case .caption1: return "OTHakgyoansimMulgyeolR"
        case let .custom(weight, _):
            return "OTHakgyoansimMulgyeol\(weight)"
        }
    }
    
    private var size: CGFloat {
        switch self {
        case .title1: return 32
        case .body1: return 20
        case .caption1: return 14
        case let .custom(_, size):
            return size
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
        case .title1: return 32
        case .body1: return 20
        case .caption1: return 14
        case let .custom(_, size):
            return size
        }
    }
    
    var kerning: CGFloat {
        return 0
    }
    
}
