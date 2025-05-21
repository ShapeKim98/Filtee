//
//  KeyAdapter.swift
//  Filtee
//
//  Created by 김도형 on 5/18/25.
//

import Foundation

import Alamofire

struct KeyAdapter: RequestAdapter {
    func adapt(
        _ urlRequest: URLRequest,
        for session: Session,
        completion: @escaping (Result<URLRequest, any Error>) -> Void
    ) {
        var request = urlRequest
        request.addValue(
            Bundle.main.sesacKey,
            forHTTPHeaderField: "SeSACKey"
        )
        completion(.success(request))
    }
}
