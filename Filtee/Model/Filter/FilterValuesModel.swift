//
//  FilterValuesModel.swift
//  Filtee
//
//  Created by 김도형 on 5/25/25.
//

import Foundation

struct FilterValuesModel {
    let brightness: Double
    let exposure: Double
    let contrast: Double
    let saturation: Double
    let sharpness: Double
    let blur: Double
    let vignette: Double
    let noiseReduction: Double
    let highlights: Double
    let shadows: Double
    let temperature: Double
    let blackPoint: Double
}

extension FilterValuesResponse {
    func toModel() -> FilterValuesModel {
        return FilterValuesModel(
            brightness: self.brightness ?? 0,
            exposure: self.exposure ?? 0,
            contrast: self.contrast ?? 0,
            saturation: self.saturation ?? 0,
            sharpness: self.sharpness ?? 0,
            blur: self.blur ?? 0,
            vignette: self.vignette ?? 0,
            noiseReduction: self.noiseReduction ?? 0,
            highlights: self.highlights ?? 0,
            shadows: self.shadows ?? 0,
            temperature: self.temperature ?? 0,
            blackPoint: self.blackPoint ?? 0
        )
    }
}
