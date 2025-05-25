//
//  FilterDetailResponse+Mock.swift
//  Filtee
//
//  Created by 김도형 on 5/25/25.
//

import Foundation

extension FilterDetailResponse {
    static let detailMock = FilterDetailResponse(
        filterId: "670bcd66539a670e42b2a3d8",
        category: "풍경",
        title: "풍경 필터",
        description: "풍경 사진을 더 멋지게!",
        files: ["/data/filters/previews_original_1712739634962.png"],
        creator: .detailMock,
        isLike: false,
        likeCount: 10,
        buyerCount: 5,
        createdAt: "9999-10-19T03:05:03.422Z",
        updatedAt: "9999-10-20T10:00:00.000Z",
        photoMetadata: .detailMock,
        filterValues: .detailMock,
        isDownloaded: true
    )
}
