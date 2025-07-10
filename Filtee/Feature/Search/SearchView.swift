//
//  SearchView.swift
//  Filtee
//
//  Created by 김도형 on 7/10/25.
//

import SwiftUI

import IdentifiedCollections

struct SearchView: View {
    @EnvironmentObject
    private var navigation: NavigationRouter<SearchPath>
    
    @Environment(\.userClient.search)
    private var userClientSearch
    
    @State
    private var nick: String = ""
    @State
    private var textFieldState: FilteeSearchTextFieldStyle.TextFieldState = .default
    @State
    private var searchTask: Task<Void, Never>?
    @State
    private var users = IdentifiedArrayOf<ProfileModel>()
    @State
    private var isEmpty: Bool = false
    @FocusState
    private var focused: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            searchField
            
            if isEmpty {
                empty
            } else {
                searchList
                
                Spacer()
            }
        }
        .filteeNavigation(title: "유저 검색")
        .dismissKeyboard(focused: $focused)
        .onChange(of: nick, perform: onChangeNick)
    }
}

// MARK: - Configure Views
private extension SearchView {
    var searchField: some View {
        TextField(text: $nick) {
            Text("작가의 이름을 입력해주세요.")
                .foregroundStyle(.gray90)
        }
        .textFieldStyle(.filteeSearch(textFieldState))
        .padding(.horizontal, 20)
        .focused($focused)
    }
    
    var searchList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(users) { user in
                    Button(action: { profileButtonAction(user: user) }) {
                        FilteeProfile(
                            profile: user,
                            showInformation: false,
                            chatButtonAction: { chatButtonAction(user: user) }
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.bottom, 68)
        }
    }
    
    var empty: some View {
        VStack {
            Spacer()
            
            Text("검색 결과가 없습니다.")
                .font(.pretendard(.body1(.medium)))
                .foregroundStyle(.gray75)
            
            Spacer()
        }
    }
}

// MARK: - Functions
private extension SearchView {
    func bodyOnAppear() {
        focused = true
    }
    
    func onChangeNick(_ newValue: String) {
        searchTask?.cancel()
        
        guard !newValue.isEmpty else {
            textFieldState = .default
            return
        }
        guard !newValue.filter({ !$0.isWhitespace }).isEmpty else {
            textFieldState = .error("공백 제외 한글자 이상 입력해주세요")
            return
        }
        
        if textFieldState != .loading {
            textFieldState = .loading
        }
        
        searchTask = Task {
            do {
                try await Task.sleep(for: .milliseconds(500))
                await fetchUsersSearch()
            } catch {
                print(error)
            }
        }
    }
    
    func chatButtonAction(user: ProfileModel) {
        navigation.push(.chat(opponentId: user.id))
    }
    
    func profileButtonAction(user: ProfileModel) {
        navigation.push(.userDetail(user: user))
    }
    
    func fetchUsersSearch() async {
        do {
            let users = try await userClientSearch(nick)
            isEmpty = users.isEmpty
            self.users = .init(uniqueElements: users)
            textFieldState = .default
        } catch {
            print(error)
        }
    }
}

#if DEBUG
#Preview {
    SearchView()
        .environment(\.userClient, .testValue)
}
#endif
