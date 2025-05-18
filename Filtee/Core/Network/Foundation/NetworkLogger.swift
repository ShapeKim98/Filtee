//
//  NetworkLogger.swift
//  Filtee
//
//  Created by 김도형 on 5/16/25.
//

import Foundation

import Alamofire

enum NetworkLogger {
    static func request(_ endPoint: URLRequestConvertible) throws {
        let request = try endPoint.asURLRequest()
        print("[ℹ️] NETWORK -> request:")
        print("""
        method: \(request.httpMethod ?? ""),
        url: \(request.url?.absoluteString ?? ""),
        """
        )
        print("headers: ", terminator: "")
        print("[")
        for header in request.allHTTPHeaderFields ?? [:] {
            print("  \(header.key): \(header.value),")
        }
        print("],\n")
        if let body = request.httpBody {
            // httpBody를 먼저 역직렬화하여 Foundation 객체로 변환
            let jsonObject = try JSONSerialization.jsonObject(with: body, options: [.fragmentsAllowed])
            let data = try JSONSerialization.data(
                withJSONObject: jsonObject,
                options: [.prettyPrinted]
            )
            print("body: \(String(data: data, encoding: .utf8) ?? "nil")")
        }
    }
    
    static func response<T: Decodable>(_ response: DataResponse<T, AFError>) throws {
        print("[ℹ️] NETWORK -> response:")
        if let urlResponse = response.response {
            print("url: \(urlResponse.url?.absoluteString ?? "N/A"),")
            print("status code: \(urlResponse.statusCode),")
        } else {
            print(String(describing: response.response))
        }
        if let data = response.data {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
            
            print("body: \(String(data: jsonData, encoding: .utf8) ?? "nil")")
        }
    }
}
