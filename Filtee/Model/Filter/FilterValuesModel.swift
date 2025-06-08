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
