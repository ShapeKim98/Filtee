//
//  HomePath.swift
//  Filtee
//
//  Created by 김도형 on 5/28/25.
//

import SwiftUICore

enum MainPath: Hashable, Sendable {
    case detail(id: String)
    case chat(opponentId: String)
}
