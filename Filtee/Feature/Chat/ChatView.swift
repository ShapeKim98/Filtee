//
//  ChatView.swift
//  Filtee
//
//  Created by 김도형 on 6/18/25.
//

import SwiftUI

import IdentifiedCollections

struct ChatView<Path: Hashable & Sendable>: View {
    @EnvironmentObject
    private var navigation: NavigationRouter<Path>
    
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
    private var chats: IdentifiedArrayOf<ChatModel> = []
    @State
    private var input: String = ""
    @State
    private var userId: String?
    @State
    private var isLoading: Bool = true
    @State
    private var hasNext: Bool = true
    @State
    private var searchKeyword: String?
    @State
    private var searchTextFieldState: FilteeSearchTextFieldStyle.TextFieldState = .default
    @State
    private var searchResult: IdentifiedArrayOf<ChatModel> = []
    @State
    private var searchTask: Task<Void, Never>?
    @State
    private var searchResultIndex = 0
    @State
    private var chatListProxy: ScrollViewProxy?
    @State
    private var nextButtonTask: Task<Void, Never>?
    
    @FocusState
    private var searchFocused: Bool
    @FocusState
    private var inputFocused: Bool
    
    private let opponentId: String
    private var roomTitle: String {
        room?.participants
            .filter { $0.id != userId }
            .compactMap(\.nick)
            .sorted(by: <)
            .joined(separator: ", ") ?? ""
    }
    private var isSearching: Bool {
        searchKeyword != nil
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
        .if(isSearching) { $0.ignoresSafeArea(.keyboard, edges: .bottom) }
        .overlay(alignment: .top) {
            if isSearching {
                searchToolbar.filteeBlurReplace()
            }
        }
        .filteeNavigation(
            title: roomTitle,
            leadingItems: toolbarLeading,
            trailingItems: toolbarTrailing
        )
        .if(isSearching){ $0.dismissKeyboard(focused: $searchFocused) }
        .if(!isSearching) { $0.dismissKeyboard(focused: $inputFocused) }
        .onChange(of: scenePhase, perform: onChangeScenePhase)
        .onChange(of: searchKeyword, perform: onChangeSearchKeyword)
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
    
    func toolbarTrailing() -> some View {
        Button(action: searchButtonAction) {
            if isSearching {
                Image(.plus)
                    .resizable()
                    .rotationEffect(.degrees(45))
            } else {
                Image(.searchEmpty)
                    .resizable()
            }
        }
        .buttonStyle(.filteeToolbar)
    }
    
    var searchToolbar: some View {
        VStack(spacing: 12) {
            searchBar
            
            Text("\(searchResultIndex + 1) / \(searchResult.count)")
                .contentTransition(.numericText())
                .font(.pretendard(.body1(.bold)))
                .foregroundStyle(.secondary)
                .animation(.default, value: searchResultIndex )
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.ultraThinMaterial)
                .clipRectangle(9999)
        }
    }
    
    var searchBar: some View {
        HStack(spacing: 8) {
            TextField(text: .init(
                get: { searchKeyword ?? "" },
                set: { searchKeyword = $0 }
            )) {
                Text("검색어를 입력해주세요.")
                    .foregroundStyle(.secondary)
            }
            .textFieldStyle(.filteeSearch(searchTextFieldState, isFloating: true))
            .focused($searchFocused)
            
            Button(action: nextSearchButtonAction) {
                Image(.chevron)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 34, height: 34)
                    .rotationEffect(.degrees(90))
                    .foregroundStyle(.secondary)
                    .padding(4)
                    .background(.ultraThinMaterial)
                    .clipRectangle(9999)
            }
            .buttonStyle(.plain)
            
            Button(action: previousSearchButtonAction) {
                Image(.chevron)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 34, height: 34)
                    .rotationEffect(.degrees(-90))
                    .foregroundStyle(.secondary)
                    .padding(4)
                    .background(.ultraThinMaterial)
                    .clipRectangle(9999)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 20)
    }
    
    var chatList: some View {
        ScrollViewReader { proxy in
            List(chats) { chat in
                chatCell(chat)
                    .padding(.horizontal, 16)
                    .listRowInsets(.init(.zero))
                    .listRowSeparator(.hidden)
                    .id(chat.id)
            }
            .listRowSpacing(4)
            .listStyle(.plain)
            .environment(\.defaultMinListRowHeight, 0)
            .onAppear { self.chatListProxy = proxy }
        }
    }
    
    @ViewBuilder
    func chatCell(_ chat: ChatModel) -> some View {
        let isMe = userId == chat.sender?.id
        let chatIndex = chats.index(id: chat.id) ?? 0
        let isLast = chatIndex == chats.count - 1
        let beforeChatIndex = chats.index(after: isLast ? chatIndex - 1 : chatIndex)
        let beforeChat = chats[beforeChatIndex]
        let calendar = Calendar.current
        let currentDay = calendar.component(.day, from: chat.createdAt)
        let beforeDay = calendar.component(.day, from: beforeChat.createdAt)
        let isCurrent = searchResult.isEmpty
        ? false
        : chat.id == searchResult[searchResultIndex].id
        
        ChatMessageView(
            chat: chat,
            isMe: isMe,
            keyword: searchKeyword,
            isCurrent: isCurrent
        )
        .if(currentDay != beforeDay) { view in
            VStack(spacing: 12) {
                dateDivider(chat.createdAt)
                
                view
            }
        }
        .if(chat.isFirst) { $0.padding(.top, 8) }
        .rotation3DEffect(
            .degrees(-180),
            axis: (0, 1, 0),
            anchor: .center
        )
        .rotationEffect(.degrees(-180))
        .if(!chats.isEmpty && hasNext && isLast) { view in
            VStack(spacing: 20) {
                view
                
                ProgressView()
                    .controlSize(.large)
                    .task(progressViewTask)
            }
        }
    }
    
    var messageInput: some View {
        HStack(spacing: 8) {
            let font = Pretendard.body2(.medium)
            
            FilteeTextEditor(text: $input, font: font)
                .focused($inputFocused)
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
    
    func searchButtonAction() {
        withAnimation(.filteeDefault) {
            if isSearching {
                searchTask?.cancel()
                searchTask = nil
                searchKeyword = nil
                searchResultIndex = 0
                searchResult.removeAll(keepingCapacity: true)
            } else {
                searchKeyword = ""
                searchFocused = true
            }
        }
    }
    
    func onChangeSearchKeyword(_ newValue: String?) {
        searchTask?.cancel()
        
        guard let newValue,
              !newValue.isEmpty,
              !newValue.filter({ !$0.isWhitespace }).isEmpty
        else {
            searchTextFieldState = .default
            return
        }
        
        if searchTextFieldState != .loading {
            searchTextFieldState = .loading
        }
        
        searchTask = Task {
            do {
                try await Task.sleep(for: .milliseconds(500))
                await searchChats()
            } catch {
                print(error)
            }
        }
    }
    
    func nextSearchButtonAction() {
        nextButtonTask?.cancel()
        guard searchResultIndex < searchResult.count - 1 else { return }
        searchResultIndex += 1
        nextButtonTask = Task {
            await fetchChatGroupsFromDateToDate()
            do {
                try await Task.sleep(for: .milliseconds(500))
                chatListProxy?.scrollTo(
                    searchResult[searchResultIndex].id,
                    anchor: .center
                )
            } catch {
                print(error)
            }
        }
    }
    
    func previousSearchButtonAction() {
        guard searchResultIndex > 0 else { return }
        searchResultIndex -= 1
        chatListProxy?.scrollTo(
            searchResult[searchResultIndex].id,
            anchor: .center
        )
    }
    
    func paginationChats() async throws {
        guard let roomId = room?.id else { return }
        let chats = try await chatPersistenceManager.paginationChat(
            roomId: roomId,
            cursor: chats.last?.createdAt
        )
        guard let chats, !chats.isEmpty else {
            hasNext = false
            return
        }
        self.chats.append(contentsOf: chats)
    }
    
    func updateNewChats(room: RoomModel) async throws {
        let next = chats.first?.createdAt.toString(.chat)
        let newChats = try await chatClientChats(room.id, next)
        for chat in newChats {
            await saveChat(chat: chat)
        }
    }
    
    func saveChat(chat: ChatModel) async {
        guard let room else { return }
        do {
            let newChat = try await chatPersistenceManager.createChat(
                chatModel: chat,
                roomModel: room
            )
            input = ""
            chats.updateOrInsert(newChat, at: 0)
            if chats.count > 1 {
                chats[1].isLast = newChat.isFirst
            }
            
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
            try await updateNewChats(room: room)
            await observeChatStream()
        } catch {
            print(error)
        }
    }
    
    func searchChats() async {
        guard let searchKeyword, let roomId = room?.id else { return }
        do {
            let result = try await chatPersistenceManager.searchChat(
                searchKeyword,
                roomId: roomId
            )
            searchResult.removeAll(keepingCapacity: true)
            searchResult.append(contentsOf: result)
            searchResultIndex = 0
            await fetchChatGroupsFromDateToDate()
            searchTextFieldState = .default
            guard !searchResult.isEmpty else { return }
            chatListProxy?.scrollTo(
                searchResult[searchResultIndex].id,
                anchor: .center
            )
        } catch {
            print(error)
        }
    }
    
    func fetchChatGroupsFromDateToDate() async {
        guard let roomId = room?.id,
              let cursor = chats.last?.createdAt,
              !searchResult.isEmpty,
              cursor > searchResult[searchResultIndex].createdAt
        else { return }
        do {
            let chats = try await chatPersistenceManager.fetchChatFromDateToDate(
                from: cursor,
                to: searchResult[searchResultIndex].createdAt,
                in: roomId
            )
            self.chats.append(contentsOf: chats)
        } catch {
            print(error)
        }
    }
}

#Preview {
    let context = PersistenceProvider(inMemory: true).container.viewContext
    
    ChatView<MainPath>(opponentId: "dev_team")
        .environment(\.userClient, .testValue)
        .environment(\.chatClient, .testValue)
        .task {
            MockDataGenerator.createMassiveData(context: context)
        }
}
