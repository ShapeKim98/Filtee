//
//  BannerDTO.swift
//  Filtee
//
//  Created by 김도형 on 7/23/25.
//

import Foundation

struct BannerDTO: DTO {
    let name: String
    let imageURL: String
    let payload: BannerDTO.Payload
    
    enum CodingKeys: String, CodingKey {
        case name
        case imageURL = "imageUrl"
        case payload
    }
}

extension BannerDTO {
    struct Payload: DTO {
        let type: String
        let value: String
    }
}
