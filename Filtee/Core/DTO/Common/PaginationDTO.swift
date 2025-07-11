//
//  PaginationDTO.swift
//  Filtee
//
//  Created by 김도형 on 7/10/25.
//

import Foundation

struct PaginationDTO<T: ResponseDTO>: ResponseDTO {
    let data: [T]
    let nextCursor: String
    
    enum CodingKeys: String, CodingKey {
        case data
        case nextCursor = "next_cursor"
    }
}
