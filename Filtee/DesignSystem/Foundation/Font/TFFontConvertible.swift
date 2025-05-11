//
//  TFFontConvertible.swift
//  Filtee
//
//  Created by 김도형 on 5/11/25.
//

import SwiftUI

protocol TFFontConvertible {
    var font: Font { get }
    var uiFont: UIFont? { get }
    var height: CGFloat { get }
    var kerning: CGFloat { get }
}
