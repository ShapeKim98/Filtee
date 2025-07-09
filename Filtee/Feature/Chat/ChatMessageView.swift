//
//  ChatMessageView.swift
//  Filtee
//
//  Created by 김도형 on 6/18/25.
//

import SwiftUI

import NukeUI

struct ChatMessageView: View {
    private let chatGroup: ChatGroupModel
    private let isMe: Bool
    
    init(chatGroup: ChatGroupModel, isMe: Bool) {
        self.chatGroup = chatGroup
        self.isMe = isMe
    }
    
    var body: some View {
        HStack(spacing: 8) {
            if !isMe {
                profileImage(chatGroup.sender?.profileImage)
            }
            
            message
        }
    }
}

// MARK: - Configure Views
private extension ChatMessageView {
    var message: some View {
        VStack(alignment: isMe ? .trailing : .leading, spacing: 8) {
            if !isMe {
                Text("\(chatGroup.sender?.nick ?? "")")
                    .font(.pretendard(.body1(.bold)))
            }
            
            ForEach(chatGroup.chats) { chat in
                bubble(chat)
            }
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .frame(maxWidth: .infinity, alignment: isMe ? .trailing : .leading)
    }
    
    @ViewBuilder
    func bubble(_ chat: ChatModel) -> some View {
        let isLast = chatGroup.chats.last?.id == chat.id
        
        HStack(alignment: .bottom, spacing: 8) {
            let pretendard = Pretendard.body1(.medium)
            
            if isMe { Spacer() }
            
            if isLast && isMe {
                Text(chat.updatedAt.toString(.chatTime))
                    .font(.pretendard(.caption2(.regular)))
                    .foregroundStyle(.gray75)
            }
            
            Text(chat.content)
                .font(.pretendard(pretendard))
                .foregroundStyle(.gray45)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(isMe ? .brightTurquoise : .deepTurquoise)
                .clipRectangle((pretendard.height + 16) / 2)
            
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
}
