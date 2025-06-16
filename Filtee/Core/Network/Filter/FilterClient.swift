//
//  FilterClient.swift
//  Filtee
//
//  Created by 김도형 on 5/21/25.
//

import SwiftUICore

struct FilterClient {
    var hotTrend: @Sendable () async throws -> [FilterModel]
    var todayFilter: @Sendable () async throws -> TodayFilterModel
    var filterDetail: @Sendable (
        _ id: String
    ) async throws -> FilterDetailModel
    var filterLike: @Sendable (
        _ id: String,
        _ isLike: Bool
    ) async throws -> Bool
    var files: @Sendable (
        _ datas: [Data]
    ) async throws -> [String]
    var filters: @Sendable (
        _ model: FilterMakeModel
    ) async throws -> Void
}

extension FilterClient: EnvironmentKey, NetworkClientConfigurable {
    typealias E = FilterEndpoint
    
    static let defaultValue = {
        return FilterClient(
            hotTrend: {
                let response: ListDTO<[FilterSummaryResponseDTO]> = try await request(.hotTrend)
                return response.data.map { $0.toModel() }
            },
            todayFilter: {
                let response: TodayFilterResponseDTO = try await request(.todayFilter)
                return response.toModel()
            },
            filterDetail: { id in
                let response: FilterResponseDTO = try await request(.filterDetail(id: id))
                return response.toModel()
            },
            filterLike: { id, isLike in
                let response: [String: Bool] = try await request(.filterLike(id: id, isLike: isLike))
                return response["like_status"] ?? false
            },
            files: { datas in
                var forms = [MultipartForm]()
                let fileName = UUID().uuidString
                
                for (index, data) in datas.enumerated() {
                    guard let fileExtension = data.fileExtensionForData(),
                          let mimeType = data.detectMimeType()
                    else { continue }
                    let imageType = index == 0 ? "original" : "filtered"
                    forms.append(MultipartForm(
                        data: data,
                        withName: "files",
                        fileName: "\(imageType)_\(fileName).\(fileExtension)",
                        mimeType: mimeType
                    ))
                }
                let response: FileResponseDTO = try await upload(.files(forms))
                return response.files
            },
            filters: { model in
                let request = model.toData()
                try await Self.request(.filters(request))
            }
        )
    }()
}

extension EnvironmentValues {
    var filterClient: FilterClient {
        get { self[FilterClient.self] }
        set { self[FilterClient.self] = newValue }
    }
}
