//
//  FilterValuesModel.swift
//  Filtee
//
//  Created by 김도형 on 5/25/25.
//

import Foundation

struct FilterValuesModel {
    var brightness: Double = 0
    var exposure: Double = 0
    var contrast: Double = 0
    var saturation: Double = 0
    var sharpness: Double = 0
    var blur: Double = 0
    var vignette: Double = 0
    var noiseReduction: Double = 0
    var highlights: Double = 0
    var shadows: Double = 0
    var temperature: Double = 0
    var blackPoint: Double = 0
}

extension FilterValuesModel {
    func toData() -> FilterValuesDTO {
        return FilterValuesDTO(
            brightness: self.brightness,
            exposure: self.exposure,
            contrast: self.contrast,
            saturation: self.saturation,
            sharpness: self.sharpness,
            blur: self.blur,
            vignette: self.vignette,
            noiseReduction: self.noiseReduction,
            highlights: self.highlights,
            shadows: self.shadows,
            temperature: self.temperature,
            blackPoint: self.blackPoint
        )
    }
}

extension FilterValuesDTO {
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
