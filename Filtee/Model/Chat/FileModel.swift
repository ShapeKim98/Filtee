//
//  FileModel.swift
//  Filtee
//
//  Created by 김도형 on 8/2/25.
//

import Foundation

struct FileModel: Identifiable {
    let id: String
    let sequence: Int16
    var data: Data?
    var type: String?
    let url: String
}
