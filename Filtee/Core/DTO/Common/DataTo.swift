//
//  DataResponse.swift
//  Filtee
//
//  Created by 김도형 on 5/21/25.
//

import Foundation

struct DataTo<T: ResponseData>: ResponseData {
    let data: T
}
