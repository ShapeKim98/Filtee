//
//  FilterValuesModel.swift
//  Filtee
//
//  Created by 김도형 on 5/25/25.
//

import Foundation

struct FilterValuesModel: Sendable, Hashable {
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
    var currentFilterValue: FilterValue = .brightness
    
    var currentValue: Float {
        switch currentFilterValue {
        case .brightness: return brightness
        case .exposure: return exposure
        case .contrast: return contrast
        case .saturation: return saturation
        case .sharpness: return sharpness
        case .blur: return blur
        case .vignette: return vignette
        case .noise: return noiseReduction
        case .highlights: return highlights
        case .shadows: return shadows
        case .temperature: return temperature
        case .blackPoint: return blackPoint
        }
    }
}

extension FilterValuesModel {
    enum FilterValue: String, CaseIterable {
        case brightness
        case exposure
        case contrast
        case saturation
        case sharpness
        case blur
        case vignette
        case noise
        case highlights
        case shadows
        case temperature
        case blackPoint
        
        var image: ImageResource {
            switch self {
            case .brightness:
                return .brightness
            case .exposure:
                return .exposure
            case .contrast:
                return .contrast
            case .saturation:
                return .saturation
            case .sharpness:
                return .sharpness
            case .blur:
                return .blur
            case .vignette:
                return .vignette
            case .noise:
                return .noise
            case .highlights:
                return .highlights
            case .shadows:
                return .shadows
            case .temperature:
                return .temperature
            case .blackPoint:
                return .blackPoint
            }
        }
        
        var title: String {
            self.rawValue.uppercased()
        }
        
        var minimum: CGFloat {
            switch self {
            case .contrast,
                 .saturation:
                return 0
            case .temperature:
                return 2000
            default: return -1
            }
        }
        
        var median: CGFloat {
            switch self {
            case .contrast,
                 .saturation:
                return 1
            case .temperature:
                return 6500
            default: return 0
            }
        }
        
        var maximum: CGFloat {
            switch self {
            case .contrast,
                 .saturation:
                return 2
            case .temperature:
                return 11000
            default: return 1
            }
        }
        
        var unit: CGFloat {
            switch self {
            case .temperature: return 100
            default: return 0.01
            }
        }
        
        var decimalUnit: CGFloat {
            switch self {
            case .temperature: return -2
            default: return 2
            }
        }
        
        var format: String {
            switch self {
            case .temperature: return "%.0f"
            default: return "%.2f"
            }
        }
    }
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
