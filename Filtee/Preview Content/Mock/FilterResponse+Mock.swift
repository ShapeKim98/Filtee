//
//  Filter+Mock.swift
//  Filtee
//
//  Created by 김도형 on 5/21/25.
//

import Foundation

extension FilterResponse {
    static let hotTrendMock = [
        FilterResponse(
            filterId: "670bcd66539a670e42b2a3d8",
            category: "풍경",
            title: "풍경 필터",
            description: "풍경 사진을 더 멋지게!",
            files: [
                "/data/filters/previews_original_1729345641848.jpg",
                "/data/filters/previews_filtered_1729345641849.jpg"
            ],
            creator: .creatorMock,
            isLike: false,
            likeCount: 15,
            buyerCount: 3,
            createdAt: "9999-10-19T03:05:03.422Z",
            updatedAt: "9999-10-19T03:05:03.422Z"
        )
    ]
}
