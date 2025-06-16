//
//  FilterValuesResponse+Mock.swift
//  Filtee
//
//  Created by 김도형 on 5/25/25.
//

import Foundation

extension FilterValuesDTO {
    static let detailMock = FilterValuesDTO(
        brightness: 0.15,
        exposure: 0.3,
        contrast: 1.05,
        saturation: 1.1,
        sharpness: 0.5,
        blur: 0.0,
        vignette: 0.2,
        noiseReduction: 0.1,
        highlights: -0.1,
        shadows: 0.15,
        temperature: 5800.0,
        blackPoint: 0.03
    )
}
