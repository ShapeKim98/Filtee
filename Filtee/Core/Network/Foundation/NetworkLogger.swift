//
//  NetworkLogger.swift
//  Filtee
//
//  Created by 김도형 on 5/16/25.
//

import Foundation

import Alamofire

struct NetworkLogger: EventMonitor {
    func requestDidResume(_ request: Request) {
        guard let request = request.request else { return }
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
            do {
                let jsonObject = try JSONSerialization.jsonObject(
                    with: body,
                    options: [.fragmentsAllowed]
                )
                let data = try JSONSerialization.data(
                    withJSONObject: jsonObject,
                    options: [.prettyPrinted]
                )
                print("body: \(String(data: data, encoding: .utf8) ?? "nil")")
            } catch { print(error) }
        }
    }
    
    // 추가: 요청 실패 이벤트
    func request(_ request: Request, didFailWithError error: AFError) {
        print("[ℹ️] NETWORK -> request failed with error: \(error)")
    }
    
    // 추가: 요청 취소 이벤트
    func requestDidCancel(_ request: Request) {
        print("[ℹ️] NETWORK -> request cancelled")
    }
    
    // 추가: 요청 완료 이벤트
    func requestDidFinish(_ request: Request) {
        guard let dataRequest = request as? DataRequest else { return }
        print("[ℹ️] NETWORK -> response:")
        dataRequest.responseData { response in
            if let urlResponse = response.response {
                print("url: \(urlResponse.url?.absoluteString ?? "N/A"),")
                print("status code: \(urlResponse.statusCode),")
            } else {
                print(String(describing: response.response))
            }
            if let data = response.data {
                do {
                    let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                    let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
                    
                    print("body: \(String(data: jsonData, encoding: .utf8) ?? "nil")")
                } catch { print(error) }
            }
        }
    }
}
