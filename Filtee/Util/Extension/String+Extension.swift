//
//  String+Extension.swift
//  Filtee
//
//  Created by 김도형 on 5/21/25.
//

import Foundation

extension String {
    var imageURL: String {
        return Bundle.main.baseURL + "/v1" + self
    }
}


