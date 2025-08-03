//
//  ChatMessageView.swift
//  Filtee
//
//  Created by 김도형 on 6/18/25.
//

import SwiftUI

import NukeUI

struct ChatMessageView: View {
    @Environment(\.dataClient)
    private var dataClient
    @Environment(\.chatPersistenceManager)
    private var chatPersistenceManager
    
    @Binding
    private var chat: ChatModel
    
    @State
    private var filesLoading = false
    @State
    private var fileTask: Task<Void, Never>?
    
    private let isMe: Bool
    private let keyword: String?
    private let isCurrent: Bool
    private var rowSizes: [Int] { computeRowSizes(chat.files.count) }
    private var cumulativeStarts: [Int] {
        var starts: [Int] = [0]
        for size in rowSizes {
            starts.append(starts.last! + size)
        }
        return starts
    }
    
    init(
        chat: Binding<ChatModel>,
        isMe: Bool,
        keyword: String?,
        isCurrent: Bool
    ) {
        self._chat = chat
        self.isMe = isMe
        self.keyword = keyword
        self.isCurrent = isCurrent
    }
    
    var body: some View {
        HStack(spacing: 8) {
            if chat.isHead && !isMe {
                profileImage(chat.sender?.profileImage)
            }
            
            message.if(!chat.isHead) { view in
                view.padding(.leading, 40)
            }
        }
    }
}

// MARK: - Configure Views
private extension ChatMessageView {
    var message: some View {
        VStack(alignment: isMe ? .trailing : .leading, spacing: 8) {
            if chat.isHead && !isMe {
                Text("\(chat.sender?.nick ?? "")")
                    .font(.pretendard(.body1(.bold)))
            }
            
            bubble
        }
        .frame(maxWidth: .infinity, alignment: isMe ? .trailing : .leading)
    }
    
    @ViewBuilder
    var bubble: some View {
        let isLast = chat.isTail
        
        HStack(alignment: .bottom, spacing: 8) {
            let pretendard = Pretendard.body1(.medium)
            
            if isMe { Spacer(minLength: 50) }
            
            if isLast && isMe {
                Text(chat.updatedAt.toString(.chatTime))
                    .font(.pretendard(.caption2(.regular)))
                    .foregroundStyle(.gray75)
            }
            
            Group {
                if let keyword, isCurrent {
                    let text = highlightString(
                        from: chat.content,
                        highlighting: keyword
                    )
                    
                    Text(text)
                } else {
                    Text(chat.content)
                }
            }
            .font(.pretendard(pretendard))
            .foregroundStyle(.gray45)
            .if(filesLoading) { view in
                VStack(alignment: .leading, spacing: 8) {
                    view
                    
                    ProgressView()
                        .controlSize(.regular)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(isMe ? .brightTurquoise : .deepTurquoise)
            .clipRectangle((pretendard.height + 16) / 2)
            .clipped()
            .if(!chat.files.isEmpty) { view in
                VStack(alignment: .leading, spacing: 2) {
                    view
                    
                    images(files: chat.files.compactMap { $0.data })
                        .clipRectangle((pretendard.height + 16) / 2 - 4)
                }
            }
            
            if isLast && !isMe {
                Text(chat.updatedAt.toString(.chatTime))
                    .font(.pretendard(.caption2(.regular)))
                    .foregroundStyle(.gray75)
            }
            
            if !isMe { Spacer(minLength: 50) }
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
    func highlightString(
        from text: String,
        highlighting keyword: String
    ) -> AttributedString {
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
            // 배경색 적용
            attributedString[attributedRange].backgroundColor = .accentColor
            attributedString[attributedRange].foregroundColor = .gray45
            
            // 다음 검색 시작점 설정
            searchStartIndex = range.upperBound
        }
        
        return attributedString
    }
    
    @ViewBuilder
    func images(files: [Data]) -> some View {
        if files.count == 1,
            let data = files.first,
            let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else {
            GeometryReader { geometry in
                let rowCount = rowSizes.count
                let spacing: CGFloat = 4
                let totalHeight = geometry.size.height
                let totalWidth = geometry.size.width
                let rowHeight = (totalHeight - spacing * CGFloat(rowCount - 1)) / CGFloat(rowCount)
                
                VStack(spacing: spacing) {
                    ForEach(0..<rowSizes.count, id: \.self) { rowIndex in
                        let cols = rowSizes[rowIndex]
                        let startIndex = cumulativeStarts[rowIndex]
                        let endIndex = cumulativeStarts[rowIndex + 1]
                        let colWidth = (totalWidth - spacing * CGFloat(cols - 1)) / CGFloat(cols)
                        
                        HStack(spacing: spacing) {
                            ForEach(startIndex..<endIndex, id: \.self) { index in
                                if let uiImage = UIImage(data: files[index]) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: colWidth, height: rowHeight)
                                        .clipped()
                                }
                            }
                        }
                    }
                }
            }
            .frame(height: CGFloat(rowSizes.count) * 100)
        }
    }
}

// MARK: - Functions
private extension ChatMessageView {
    func computeRowSizes(_ n: Int) -> [Int] {
        if n <= 0 {
            return []
        }
        let k = n / 3
        let rem = n % 3
        var sizes: [Int] = []
        if rem == 0 {
            sizes = Array(repeating: 3, count: k)
        } else if rem == 1 {
            if k > 0 {
                sizes = Array(repeating: 3, count: k - 1)
                sizes += [2, 2]
            } else {
                sizes = [1] // Fallback for n=1, though n >= 3 is assumed.
            }
        } else {
            sizes = Array(repeating: 3, count: k)
            sizes.append(2)
        }
        return sizes
    }
}
