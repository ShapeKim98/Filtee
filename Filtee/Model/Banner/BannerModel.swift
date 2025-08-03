//
//  BannerModel.swift
//  Filtee
//
//  Created by 김도형 on 7/23/25.
//

import Foundation

struct BannerModel: Identifiable, Hashable {
    let id = UUID().uuidString
    let name: String
    let imageURL: String
    let payload: Payload
}

extension BannerModel {
    struct Payload: Hashable {
        let type: String
        let value: String
    }
}

extension BannerDTO.Payload {
    func toModel() -> BannerModel.Payload {
        return BannerModel.Payload(
            type: self.type,
            value: self.value
        )
    }
}

extension BannerDTO {
    func toModel() -> BannerModel {
        return BannerModel(
            name: self.name,
            imageURL: self.imageURL.url,
            payload: self.payload.toModel()
        )
    }
}
