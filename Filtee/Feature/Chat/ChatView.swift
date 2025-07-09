//
//  ChatView.swift
//  Filtee
//
//  Created by 김도형 on 6/18/25.
//

import SwiftUI

import IdentifiedCollections

struct ChatView: View {
    @EnvironmentObject
    private var navigation: NavigationRouter<MainPath>
    
    @Environment(\.userClient.meProfile)
    private var userClientMeProfile
    @Environment(\.chatPersistenceManager)
    private var chatPersistenceManager
    @Environment(\.chatClient.chats)
    private var chatClientChats
    @Environment(\.chatClient.sendChats)
    private var chatClientSendChats
    @Environment(\.chatClient.createChats)
    private var chatClientCreateChats
    @Environment(\.chatClient.webSocketConnect)
    private var chatClientWebSocketConnect
    @Environment(\.chatClient.webSocketDisconnect)
    private var chatClientWebSocketDisconnect
    @Environment(\.chatClient.webSocketStream)
    private var chatClientWebSocketStream
    @Environment(\.scenePhase)
    private var scenePhase
    
    @State
    private var room: RoomModel?
    @State
    private var sender: UserInfoModel?
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
    
    private let opponentId: String
    private var roomTitle: String {
        room?.participants
            .filter { $0.id != userId }
            .compactMap(\.nick)
            .sorted(by: <)
            .joined(separator: ", ") ?? ""
    }
    
    init(opponentId: String) {
        self.opponentId = opponentId
    }
    
    var body: some View {
        VStack(spacing: 0) {
            chatList
                .rotation3DEffect(.degrees(180), axis: (0, 1, 0), anchor: .center)
                .rotationEffect(.degrees(180))
            
            messageInput
        }
        .filteeNavigation(
            title: roomTitle,
            leadingItems: toolbarLeading
        )
        .onChange(of: scenePhase, perform: onChangeScenePhase)
        .task(bodyTask)
        .onDisappear(perform: bodyOnDisappear)
    }
}

// MARK: Configure Views
private extension ChatView {
    func toolbarLeading() -> some View {
        Button(action: backButtonAction) {
            Image(.chevron).resizable()
        }
        .buttonStyle(.filteeToolbar)
    }
    
    var chatList: some View {
        List(chats) { chat in
            chatCell(chat)
                .padding(.horizontal, 16)
                .listRowInsets(.init(.zero))
                .listRowSeparator(.hidden)
                .id(chat.id)
        }
        .listRowSpacing(16)
        .listStyle(.plain)
    }
    
    @ViewBuilder
    func chatCell(_ chat: ChatGroupModel) -> some View {
        let isMe = userId == chat.sender?.id
        let chatIndex = chats.index(id: chat.id) ?? 0
        let isLast = chatIndex == chats.count - 1
        let beforeChatIndex = chats.index(after: isLast ? chatIndex - 1 : chatIndex)
        let beforeChat = chats[beforeChatIndex]
        let calendar = Calendar.current
        let currentDay = calendar.component(.day, from: chat.latestedAt)
        let beforeDay = calendar.component(.day, from: beforeChat.latestedAt)
        
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
            userId = try await userClientMeProfile().userId
            let room = try await chatClientCreateChats(opponentId)
            self.room = try await chatPersistenceManager.createRoom(room)
            await connectChatWebSocket()
            print(#function)
        } catch {
            print(error)
        }
    }
    
    func sendButtonAction() {
        Task { await sendChat() }
    }
    
    func inputTextEditorOnSubmit() {
        Task { await sendChat() }
    }
    
    @Sendable
    func progressViewTask() async {
        do {
            try await paginationChats()
        } catch {
            print(error)
        }
    }
    
    func onChangeScenePhase(_ scenePhase: ScenePhase) {
        Task {
            switch scenePhase {
            case .background, .inactive:
                try await chatClientWebSocketDisconnect()
            case .active:
                await connectChatWebSocket()
            @unknown default: break
            }
        }
    }
    
    func bodyOnDisappear() {
        Task { try await chatClientWebSocketDisconnect() }
    }
    
    func backButtonAction() {
        navigation.pop()
    }
    
    func paginationChats() async throws {
        guard let roomId = room?.id else { return }
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
    
    func updateNewChats(roomId: String) async throws {
        let next = chats.first?.latestedAt.toString(.chat)
        let newChats = try await chatClientChats(roomId, next)
        for chat in newChats {
            await saveChat(chat: chat)
        }
    }
    
    func saveChat(chat: ChatModel) async {
        do {
            let newChat = try await chatPersistenceManager.createChat(
                chatModel: chat,
                lastChatGroup: chats.first
            )
            input = ""
            chats.updateOrInsert(newChat, at: 0)
        } catch { print(error) }
    }
    
    func sendChat() async {
        guard let roomId = room?.id else { return }
        do {
            try await chatClientSendChats(roomId, input)
        } catch {
            print(error)
        }
    }
    
    func observeChatStream() async {
        do {
            for try await chat in chatClientWebSocketStream() {
                await saveChat(chat: chat)
            }
        } catch {
            print(error)
        }
    }
    
    func connectChatWebSocket() async {
        guard let room else { return }
        do {
            try await chatClientWebSocketConnect(room.id)
            try await paginationChats()
            try await updateNewChats(roomId: room.id)
            await observeChatStream()
        } catch {
            print(error)
        }
    }
}

#Preview {
    ChatView(opponentId: "")
        .environment(\.managedObjectContext, PersistenceProvider(inMemory: true).container.viewContext)
}
