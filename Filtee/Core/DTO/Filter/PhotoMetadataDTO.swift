//
//  PhotoMetaDataResponse.swift
//  Filtee
//
//  Created by 김도형 on 5/25/25.
//

import Foundation

struct PhotoMetadataDTO: DTO {
    let camera: String?
    let lensInfo: String?
    let focalLength: Double?
    let aperture: Double?
    let iso: Int?
    let shutterSpeed: String?
    let pixelHeight: Int?
    let pixelWidth: Int?
    let fileSize: Int?
    let format: String?
    let dateTimeOriginal: String?
    let latitude: Double?
    let longitude: Double?
    
    enum CodingKeys: String, CodingKey {
        case camera
        case lensInfo = "lens_info"
        case focalLength = "focal_length"
        case aperture
        case iso
        case shutterSpeed = "shutter_speed"
        case pixelHeight = "pixel_height"
        case pixelWidth = "pixel_width"
        case fileSize = "file_size"
        case format
        case dateTimeOriginal = "date_time_original"
        case latitude
        case longitude
    }
}
