//
//  IamportModel.swift
//  Filtee
//
//  Created by 김도형 on 6/16/25.
//

import Foundation

import iamport_ios

struct IamportModel {
    let success: Bool
    let impUid: String
}

extension IamportResponse {
    func toModel() -> IamportModel {
        return IamportModel(
            success: self.success ?? false,
            impUid: self.imp_uid ?? ""
        )
    }
}
