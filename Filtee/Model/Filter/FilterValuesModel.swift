//
//  FilterValuesModel.swift
//  Filtee
//
//  Created by 김도형 on 5/25/25.
//

import Foundation

struct FilterValuesModel: Sendable {
    var brightness: Float = 0
    var exposure: Float = 0
    var contrast: Float = 1
    var saturation: Float = 1
    var sharpness: Float = 0
    var blur: Float = 0
    var vignette: Float = 0
    var noiseReduction: Float = 0
    var highlights: Float = 0
    var shadows: Float = 0
    var temperature: Float = 6500
    var blackPoint: Float = 0
}

extension FilterValuesModel {
    func toData() -> FilterValuesDTO {
        return FilterValuesDTO(
            brightness: Double(self.brightness),
            exposure: Double(self.exposure),
            contrast: Double(self.contrast),
            saturation: Double(self.saturation),
            sharpness: Double(self.sharpness),
            blur: Double(self.blur),
            vignette: Double(self.vignette),
            noiseReduction: Double(self.noiseReduction),
            highlights: Double(self.highlights),
            shadows: Double(self.shadows),
            temperature: Double(self.temperature),
            blackPoint: Double(self.blackPoint)
        )
    }
}

extension FilterValuesDTO {
    func toModel() -> FilterValuesModel {
        return FilterValuesModel(
            brightness: Float(self.brightness ?? 0),
            exposure: Float(self.exposure ?? 0),
            contrast: Float(self.contrast ?? 0),
            saturation: Float(self.saturation ?? 0),
            sharpness: Float(self.sharpness ?? 0),
            blur: Float(self.blur ?? 0),
            vignette: Float(self.vignette ?? 0),
            noiseReduction: Float(self.noiseReduction ?? 0),
            highlights: Float(self.highlights ?? 0),
            shadows: Float(self.shadows ?? 0),
            temperature: Float(self.temperature ?? 0),
            blackPoint: Float(self.blackPoint ?? 0)
        )
    }
}
