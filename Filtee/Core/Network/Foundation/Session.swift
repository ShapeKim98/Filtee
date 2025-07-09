//
//  Session.swift
//  Filtee
//
//  Created by 김도형 on 5/24/25.
//

import Foundation

import Alamofire
import SocketIO

let defaultSession = Session(
    interceptor: Interceptor(
        adapters: [KeyAdapter()],
        interceptors: [TokenInterceptor()]
    ),
    eventMonitors: [NetworkLogger()]
)

let nonTokenSession = Session(
    interceptor: Interceptor(adapters: [KeyAdapter()]),
    eventMonitors: [NetworkLogger()]
)

let refreshSession = Session(
    interceptor: Interceptor(adapters: [KeyAdapter(), TokenInterceptor()]),
    eventMonitors: [NetworkLogger()]
)

let cachedSession = {
    let cache = URLCache(
        memoryCapacity: 1 * 1024 * 1024,
        diskCapacity: 1 * 1024 * 1024,
        diskPath: "alamofire_cache"
    )
    
    // URLSessionConfiguration 설정
    let configuration = URLSessionConfiguration.default
    configuration.urlCache = cache
    configuration.requestCachePolicy = .returnCacheDataElseLoad
    return Session(
        configuration: configuration,
        interceptor: Interceptor(
            adapters: [KeyAdapter()],
            interceptors: [TokenInterceptor()]
        ),
        eventMonitors: [NetworkLogger()]
    )
}()
