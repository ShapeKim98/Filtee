//
//  FilterClient.swift
//  Filtee
//
//  Created by 김도형 on 5/21/25.
//

import SwiftUICore

struct FilterClient {
    var hotTrend: @Sendable () async throws -> [FilterModel]
    var todayFilter: @Sendable () async throws -> TodayFilterModel
}

extension FilterClient: EnvironmentKey, NetworkClientConfigurable {
    typealias E = FilterEndpoint
    
    static let defaultValue = {
        return FilterClient(
            hotTrend: {
                let response: DataTo<[FilterResponse]> = try await request(.hotTrend)
                return response.data.map { $0.toModel() }
            },
            todayFilter: {
                let response: TodayFilterResponse = try await request(.todayFilter)
                return response.toModel()
            }
        )
    }()
}

extension EnvironmentValues {
    var filterClient: FilterClient {
        get { self[FilterClient.self] }
        set { self[FilterClient.self] = newValue }
    }
}
