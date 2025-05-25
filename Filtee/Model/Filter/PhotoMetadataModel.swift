//
//  PhotoMetadataModel.swift
//  Filtee
//
//  Created by 김도형 on 5/25/25.
//

import Foundation

struct PhotoMetadataModel {
    let camera: String?
    let lensInfo: String?
    let focalLength: Int?
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
}

extension PhotoMetadataResponse {
    func toModel() -> PhotoMetadataModel {
        return PhotoMetadataModel(
            camera: self.camera,
            lensInfo: self.lensInfo,
            focalLength: self.focalLength,
            aperture: self.aperture,
            iso: self.iso,
            shutterSpeed: self.shutterSpeed,
            pixelHeight: self.pixelHeight,
            pixelWidth: self.pixelWidth,
            fileSize: self.fileSize,
            format: self.format,
            dateTimeOriginal: self.dateTimeOriginal,
            latitude: self.latitude,
            longitude: self.longitude
        )
    }
}
