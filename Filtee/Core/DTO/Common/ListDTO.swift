//
//  DataResponse.swift
//  Filtee
//
//  Created by 김도형 on 5/21/25.
//

import Foundation

struct ListDTO<T: ResponseDTO>: ResponseDTO {
    let data: T
}
