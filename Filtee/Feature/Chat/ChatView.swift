//
//  ChatView.swift
//  Filtee
//
//  Created by 김도형 on 6/18/25.
//

import SwiftUI

import IdentifiedCollections

struct ChatView: View {
    @Environment(\.userClient.meProfile)
    private var userClientMeProfile
    @Environment(\.chatPersistenceManager)
    private var chatPersistenceManager
    
    @FetchRequest
    private var rooms: FetchedResults<RoomModel>
    @State
    private var chats: IdentifiedArrayOf<ChatGroupModel> = []
    @State
    private var input: String = ""
    @State
    private var userId: String?
    @State
    private var isLoading: Bool = true
    @State
    private var cursor: Date?
    @State
    private var hasNext: Bool = true
    
    private let roomId: String
    
    private var room: RoomModel? { rooms.first }
    private var participants: Set<SenderModel> {
        return room?.participants as? Set<SenderModel> ?? []
    }
    private var roomTitle: String {
        participants
            .compactMap(\.nick)
            .sorted(by: <)
            .joined(separator: ", ")
    }
    private var sender: SenderModel? {
        guard let userId else { return nil }
        return participants.first(where: { $0.userId == userId })
    }
    
    init(roomId: String) {
        self.roomId = roomId
        self._rooms = FetchRequest<RoomModel>(
            sortDescriptors: [],
            predicate: NSPredicate(format: "roomId == %@", roomId)
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            chatList
                .rotation3DEffect(.degrees(180), axis: (0, 1, 0), anchor: .center)
                .rotationEffect(.degrees(180))
            
            messageInput
        }
        .filteeNavigation(title: roomTitle)
        .task(bodyTask)
    }
}

// MARK: Configure Views
private extension ChatView {
    var chatList: some View {
        List(chats) { chat in
                .padding(.horizontal, 16)
                .listRowInsets(.init(.zero))
                .id(chat.id)
        }
        .listRowSpacing(16)
        .listStyle(.plain)
    }
    
    @ViewBuilder
    func chatCell(_ chat: ChatGroupModel) -> some View {
        let isMe = userId == chat.sender?.userId
        let chatIndex = chats.index(id: chat.id) ?? 0
        let isLast = chatIndex == chats.count - 1
        let beforeChatIndex = chats.index(after: isLast ? chatIndex - 1 : chatIndex)
        let beforeChat = chats[beforeChatIndex]
        let calendar = Calendar.current
        let currentDay = calendar.component(.day, from: chat.latestedAt ?? .now)
        let beforeDay = calendar.component(.day, from: beforeChat.latestedAt ?? .now)
        
        ChatMessageView(chatGroup: chat, isMe: isMe)
            .if(currentDay != beforeDay) { view in
                VStack(spacing: 16) {
                    dateDivider(chat.latestedAt)
                    
                    view
                }
            }
            .rotation3DEffect(
                .degrees(-180),
                axis: (0, 1, 0),
                anchor: .center
            )
            .rotationEffect(.degrees(-180))
            .if(!chats.isEmpty && hasNext && isLast) { view in
                VStack(spacing: 20) {
                    ProgressView()
                        .controlSize(.large)
                        .task(progressViewTask)
                    
                    view
                }
            }
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
            
            Button(action: sendButtonAction) {
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
    
    @ViewBuilder
    func dateDivider(_ date: Date?) -> some View {
        if let date {
            Text(date.toString(.chatDateDivider))
                .font(.pretendard(.body2(.regular)))
                .foregroundStyle(.gray45)
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(.deepTurquoise)
                .clipRectangle(9999)
        }
    }
}

// MARK: Functions
private extension ChatView {
    @Sendable
    func bodyTask() async {
        defer { isLoading = false }
        do {
//            let myInfo = try await userClientMeProfile()
//            userId = myInfo.userId
            userId = participants.first(where: { $0.nick == "장현우" })?.userId
            try await paginationChats()
        } catch {
            print(error)
        }
    }
    
    func sendButtonAction() {
        saveSendChat()
    }
    
    func inputTextEditorOnSubmit() {
        saveSendChat()
    }
    
    @Sendable
    func progressViewTask() async {
        do {
            try await paginationChats()
        } catch {
            print(error)
        }
    }
    
    func paginationChats() async throws {
        let chats = try await chatPersistenceManager.paginationChatGroups(
            roomId: roomId,
            cursor: cursor
        )
        guard let chats, let cursor = chats.last?.latestedAt else {
            hasNext = false
            return
        }
        self.cursor = cursor
        self.chats.append(contentsOf: chats)
    }
    
    func saveSendChat() {
        Task {
            guard let sender, let room else { return }
            do {
                let newChat = try await chatPersistenceManager.createChat(
                    chatId: UUID().uuidString,
                    content: input,
                    room: room,
                    sender: sender,
                    createdAt: .now,
                    updatedAt: .now,
                    lastChatGroup: chats.first
                )
                input = ""
                if chats.first?.id == newChat.id {
                    chats.update(newChat, at: 0)
                } else {
                    chats.insert(newChat, at: 0)
                }
            } catch { print(error) }
        }
    }
}

#Preview {
    ChatView(roomId: "general")
        .environment(\.managedObjectContext, PersistenceProvider(inMemory: true).container.viewContext)
}
