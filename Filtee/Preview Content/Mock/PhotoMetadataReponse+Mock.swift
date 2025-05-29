//
//  PhotoMetadataReponse+Mock.swift
//  Filtee
//
//  Created by 김도형 on 5/25/25.
//

import Foundation

extension PhotoMetadataDTO {
    static let detailMock = PhotoMetadataDTO(
        camera: "Apple iPhone 16 Pro",
        lensInfo: "와이드 카메라",
        focalLength: 50,
        aperture: 4.0,
        iso: 100,
        shutterSpeed: "1/125 sec",
        pixelHeight: 5464,
        pixelWidth: 8192,
        fileSize: 25000000,
        format: "JPEG",
        dateTimeOriginal: "9999-10-20T15:30:00Z",
        latitude: 37.51775,
        longitude: 126.886557
    )
}
