//
//  DataClient.swift
//  Filtee
//
//  Created by 김도형 on 7/28/25.
//

import SwiftUICore

import Alamofire

struct DataClient {
    var requestData: @Sendable(
        _ url: String
    ) async throws -> Data
}

extension DataClient: EnvironmentKey {
    static let defaultValue = {
        return DataClient(
            requestData: { url in
                let response = await defaultSession.request(url)
                    .validate(statusCode: 200..<300)
                    .serializingData()
                    .response
                
                switch response.result {
                case .success(let value):
                    return value
                case .failure(let error):
                    if case let AFError.requestRetryFailed(
                        retryError: retryError,
                        originalError: _
                    ) = error {
                        throw retryError
                    }
                    guard let data = response.data else {
                        throw error
                    }
                    throw error
                }
            }
        )
    }()
}

extension EnvironmentValues {
    var dataClient: DataClient {
        get { self[DataClient.self] }
        set { self[DataClient.self] = newValue }
    }
}

