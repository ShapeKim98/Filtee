//
//  ChatView.swift
//  Filtee
//
//  Created by 김도형 on 6/18/25.
//

import SwiftUI

struct ChatView: View {
    @Environment(\.managedObjectContext)
    private var viewContext
    @Environment(\.userClient.meProfile)
    private var userClientmeProfile
    
    @FetchRequest
    private var rooms: FetchedResults<RoomModel>
    @State
    private var input: String = ""
    @State
    private var userId: String?
    @State
    private var isLoading: Bool = true
    
    private var room: RoomModel? { rooms.first }
    private var chats: [ChatGroupModel] {
        let groupSet = room?.chats as? Set<ChatGroupModel> ?? []
        return groupSet.sorted { ($0.latestedAt ?? Date.distantPast) < ($1.latestedAt ?? Date.distantPast) }
    }
    
    init(roomId: String) {
        self._rooms = FetchRequest<RoomModel>(
            sortDescriptors: [],
            predicate: NSPredicate(format: "roomId == %@", roomId)
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(content: content)
                .rotationEffect(.degrees(180))
            
            messageInput
        }
    }
}

// MARK: Configure Views
private extension ChatView {
    func content() -> some View {
        LazyVStack(spacing: 16) {
            ForEach(chats) { chat in
                let isMe = userId == chat.sender?.userId
                ChatMessageView(chatGroup: chat, isMe: isMe)
            }
        }
        .rotationEffect(.degrees(-180))
        .padding(.horizontal, 16)
    }
    
    var messageInput: some View {
        HStack(spacing: 8) {
            let font = Pretendard.body2(.medium)
            
            FilteeTextEditor(text: $input, font: font)
                .padding(.vertical, 4)
                .padding(.horizontal, 12)
                .background(.deepTurquoise)
                .clipRectangle(font.height + 8)
                .frame(maxWidth: .infinity)
            
            Button(action: {}) {
                Image(systemName: "arrow.up")
                    .resizable()
                    .frame(width: 12, height: 12)
                    .foregroundStyle(.blackTurquoise)
                    .frame(width: 32, height: 32)
                    .background(.brightTurquoise)
                    .clipRectangle(9999)
            }
        }
        .padding(16)
    }
}

// MARK: Functions
private extension ChatView {
    @Sendable
    func bodyTask() async {
        defer { isLoading = false }
        do {
            let myInfo = try await userClientmeProfile()
            userId = myInfo.userId
        } catch {
            print(error)
        }
    }
}

#Preview {
    ChatView(roomId: "general")
        .environment(\.managedObjectContext, PersistenceProvider(inMemory: true).container.viewContext)
}
