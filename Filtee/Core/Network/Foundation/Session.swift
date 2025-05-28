//
//  Session.swift
//  Filtee
//
//  Created by 김도형 on 5/24/25.
//

import Foundation

import Alamofire

let filteeSession = Session(eventMonitors: [NetworkLogger()])

let imageSession = Session(
    interceptor: Interceptor(
        adapters: [KeyAdapter()],
        interceptors: [TokenInterceptor()]
    ),
    eventMonitors: [NetworkLogger()]
)

let refreshSession = Session(
    interceptor: Interceptor(adapters: [KeyAdapter(), TokenInterceptor()]),
    eventMonitors: [NetworkLogger()]
)
