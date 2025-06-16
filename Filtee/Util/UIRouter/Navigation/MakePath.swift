//
//  MakePath.swift
//  Filtee
//
//  Created by 김도형 on 6/10/25.
//

import SwiftUI

enum MakePath: Hashable, Sendable {
    case edit(
        filteredImage: Binding<CGImage?>,
        originalImage: Binding<UIImage?>,
        filterValues: Binding<FilterValuesModel>
    )
}
