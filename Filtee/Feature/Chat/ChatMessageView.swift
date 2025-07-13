//
//  ChatMessageView.swift
//  Filtee
//
//  Created by 김도형 on 6/18/25.
//

import SwiftUI

import NukeUI

struct ChatMessageView: View {
    private let chat: ChatModel
    private let isMe: Bool
    private let keyword: String?
    private let isCurrent: Bool
    
    init(
        chat: ChatModel,
        isMe: Bool,
        keyword: String?,
        isCurrent: Bool
    ) {
        self.chat = chat
        self.isMe = isMe
        self.keyword = keyword
        self.isCurrent = isCurrent
    }
    
    var body: some View {
        HStack(spacing: 8) {
            if chat.isFirst && !isMe {
                profileImage(chat.sender?.profileImage)
            }
            
            message.if(!chat.isFirst) { view in
                view.padding(.leading, 40)
            }
        }
    }
}

// MARK: - Configure Views
private extension ChatMessageView {
    var message: some View {
        VStack(alignment: isMe ? .trailing : .leading, spacing: 8) {
            if chat.isFirst && !isMe {
                Text("\(chat.sender?.nick ?? "")")
                    .font(.pretendard(.body1(.bold)))
            }
            
            bubble
        }
        .frame(maxWidth: .infinity, alignment: isMe ? .trailing : .leading)
    }
    
    @ViewBuilder
    var bubble: some View {
        let isLast = chat.isLast
        
        HStack(alignment: .bottom, spacing: 8) {
            let pretendard = Pretendard.body1(.medium)
            
            if isMe { Spacer() }
            
            if isLast && isMe {
                Text(chat.updatedAt.toString(.chatTime))
                    .font(.pretendard(.caption2(.regular)))
                    .foregroundStyle(.gray75)
            }
            
            Group {
                if let keyword, isCurrent {
                    let text = highlightString(from: chat.content, highlighting: keyword)
                    
                    Text(text)
                } else {
                    Text(chat.content)
                }
            }
            .font(.pretendard(pretendard))
            .foregroundStyle(.gray45)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(isMe ? .brightTurquoise : .deepTurquoise)
            .clipRectangle((pretendard.height + 16) / 2)
            .clipped()
            
            if isLast && !isMe {
                Text(chat.updatedAt.toString(.chatTime))
                    .font(.pretendard(.caption2(.regular)))
                    .foregroundStyle(.gray75)
            }
            
            if !isMe { Spacer() }
        }
        .frame(maxWidth: .infinity)
    }
    
    func profileImage(_ profileImage: String?) -> some View {
        LazyImage(url: URL(string: profileImage ?? "")) { state in
            lazyImageTransform(state) { image in
                image.aspectRatio(contentMode: .fill)
            }
        }
        .frame(width: 32, height: 32)
        .clipRectangle(9999)
        .clipped()
        .roundedRectangleStroke(
            radius: 9999,
            color: .gray75.opacity(0.5)
        )
        .frame(maxHeight: .infinity, alignment: .top)
    }
    
    // MARK: - 단일 키워드 하이라이트
    func highlightString(from text: String, highlighting keyword: String) -> AttributedString {
        var attributedString = AttributedString(text)
        
        // 대소문자 구분 없이 검색
        let searchText = text.lowercased()
        let searchKeyword = keyword.lowercased()
        
        var searchStartIndex = searchText.startIndex
        
        while
            let range = searchText.range(
                of: searchKeyword,
                range: searchStartIndex..<searchText.endIndex
            ),
            let attributedRange = Range(range, in: attributedString)
        {
            // AttributedString의 범위로 변환
            
            
            // 배경색 적용
            attributedString[attributedRange].backgroundColor = .accentColor
            attributedString[attributedRange].foregroundColor = .gray45
            
            // 다음 검색 시작점 설정
            searchStartIndex = range.upperBound
        }
        
        return attributedString
    }
}
