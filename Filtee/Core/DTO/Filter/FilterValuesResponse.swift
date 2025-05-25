//
//  FilterValuesResponse.swift
//  Filtee
//
//  Created by 김도형 on 5/25/25.
//

import Foundation

struct FilterValuesResponse: ResponseData {
    let brightness: Double?
    let exposure: Double?
    let contrast: Double?
    let saturation: Double?
    let sharpness: Double?
    let blur: Double?
    let vignette: Double?
    let noiseReduction: Double?
    let highlights: Double?
    let shadows: Double?
    let temperature: Double?
    let blackPoint: Double?
    
    enum CodingKeys: String, CodingKey {
        case brightness
        case exposure
        case contrast
        case saturation
        case sharpness
        case blur
        case vignette
        case noiseReduction = "noise_reduction"
        case highlights
        case shadows
        case temperature
        case blackPoint = "black_point"
    }
}
