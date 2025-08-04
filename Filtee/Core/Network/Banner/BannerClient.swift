//
//  BannerClient.swift
//  Filtee
//
//  Created by 김도형 on 7/23/25.
//

import SwiftUICore

import IdentifiedCollections

struct BannerClient {
    var bannersMain: @Sendable() async throws -> IdentifiedArrayOf<BannerModel>
}

extension BannerClient: EnvironmentKey, NetworkClientConfigurable {
    typealias E = BannerEndpoint
    
    static let defaultValue: BannerClient = {
        return BannerClient(
            bannersMain: {
                let response: ListDTO<[BannerDTO]> = try await request(.bannersMain)
                return IdentifiedArray(uniqueElements: response.data.map { $0.toModel() })
            }
        )
    }()
}

extension EnvironmentValues {
    var bannerClient: BannerClient {
        get { self[BannerClient.self] }
        set { self[BannerClient.self] = newValue }
    }
}
