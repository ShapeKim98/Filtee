//
//  ChatDataModel+Mock.swift
//  Filtee
//
//  Created by 김도형 on 6/18/25.
//

import SwiftUI
import CoreData

// MARK: - 목 데이터 생성기
struct MockDataGenerator {
    static func createMockData(context: NSManagedObjectContext) {
        // 기존 데이터 삭제 (선택사항)
        clearAllData(context: context)
        
        // 1. 사용자 생성
        let users = createUsers(context: context)
        
        // 2. 채팅방 생성
        let rooms = createRooms(context: context)
        
        // 3. 채팅방에 참여자 추가
        assignParticipantsToRooms(rooms: rooms, users: users)
        
        // 4. 메시지 및 그룹 생성
        createMessagesAndGroups(rooms: rooms, users: users, context: context)
        
        // 저장
        saveContext(context)
    }
    
    // MARK: - 사용자 생성
    private static func createUsers(context: NSManagedObjectContext) -> [SenderModel] {
        let userData = [
            ("user001", "김철수", "https://picsum.photos/100/100?random=1"),
            ("user002", "이영희", "https://picsum.photos/100/100?random=2"),
            ("user003", "박민수", "https://picsum.photos/100/100?random=3"),
            ("user004", "최지혜", "https://picsum.photos/100/100?random=4"),
            ("user005", "정호준", "https://picsum.photos/100/100?random=5"),
            ("user006", "윤서아", nil), // 프로필 이미지 없음
            ("user007", "김도현", "https://picsum.photos/100/100?random=7"),
            ("user008", "이수민", nil), // 프로필 이미지 없음
        ]
        
        var users: [SenderModel] = []
        
        for (userId, nick, profileImage) in userData {
            let user = SenderModel(context: context)
            user.userId = userId
            user.nick = nick
            user.profileImage = profileImage
            users.append(user)
        }
        
        return users
    }
    
    // MARK: - 채팅방 생성
    private static func createRooms(context: NSManagedObjectContext) -> [RoomModel] {
        let roomData = [
            ("general", "일반 채팅방"),
            ("dev_team", "개발팀 채팅방"),
            ("design_team", "디자인팀 채팅방"),
            ("project_alpha", "프로젝트 알파"),
            ("random_chat", "자유 대화방"),
        ]
        
        var rooms: [RoomModel] = []
        
        for (roomId, _) in roomData {
            let room = RoomModel(context: context)
            room.roomId = roomId
            room.createdAt = Date().addingTimeInterval(-Double.random(in: 86400...604800)) // 1-7일 전
            room.updatedAt = Date()
            rooms.append(room)
        }
        
        return rooms
    }
    
    // MARK: - 채팅방 참여자 할당
    private static func assignParticipantsToRooms(rooms: [RoomModel], users: [SenderModel]) {
        // 일반 채팅방 - 모든 사용자 참여
        if let generalRoom = rooms.first(where: { $0.roomId == "general" }) {
            for user in users {
                generalRoom.addToParticipants(user)
            }
        }
        
        // 개발팀 채팅방 - 개발자들만
        if let devRoom = rooms.first(where: { $0.roomId == "dev_team" }) {
            let devUsers = Array(users.prefix(4)) // 처음 4명
            for user in devUsers {
                devRoom.addToParticipants(user)
            }
        }
        
        // 디자인팀 채팅방 - 디자이너들만
        if let designRoom = rooms.first(where: { $0.roomId == "design_team" }) {
            let designUsers = Array(users.suffix(4)) // 마지막 4명
            for user in designUsers {
                designRoom.addToParticipants(user)
            }
        }
        
        // 프로젝트 알파 - 특정 멤버들
        if let projectRoom = rooms.first(where: { $0.roomId == "project_alpha" }) {
            let projectUsers = [users[0], users[2], users[4], users[6]] // 선택적으로
            for user in projectUsers {
                projectRoom.addToParticipants(user)
            }
        }
        
        // 자유 대화방 - 랜덤 참여자
        if let randomRoom = rooms.first(where: { $0.roomId == "random_chat" }) {
            let randomUsers = users.shuffled().prefix(5) // 랜덤 5명
            for user in randomUsers {
                randomRoom.addToParticipants(user)
            }
        }
    }
    
    // MARK: - 메시지 및 그룹 생성
    private static func createMessagesAndGroups(rooms: [RoomModel], users: [SenderModel], context: NSManagedObjectContext) {
        
        // 일반 채팅방 메시지
        if let generalRoom = rooms.first(where: { $0.roomId == "general" }) {
            createGeneralRoomMessages(room: generalRoom, users: users, context: context)
        }
        
        // 개발팀 채팅방 메시지
        if let devRoom = rooms.first(where: { $0.roomId == "dev_team" }) {
            createDevTeamMessages(room: devRoom, users: Array(users.prefix(4)), context: context)
        }
        
        // 디자인팀 채팅방 메시지
        if let designRoom = rooms.first(where: { $0.roomId == "design_team" }) {
            createDesignTeamMessages(room: designRoom, users: Array(users.suffix(4)), context: context)
        }
        
        // 프로젝트 알파 메시지
        if let projectRoom = rooms.first(where: { $0.roomId == "project_alpha" }) {
            let projectUsers = [users[0], users[2], users[4], users[6]]
            createProjectMessages(room: projectRoom, users: projectUsers, context: context)
        }
        
        // 자유 대화방 메시지
        if let randomRoom = rooms.first(where: { $0.roomId == "random_chat" }) {
            let randomUsers = Array(users.shuffled().prefix(5))
            createRandomMessages(room: randomRoom, users: randomUsers, context: context)
        }
    }
    
    // MARK: - 일반 채팅방 메시지 생성
    private static func createGeneralRoomMessages(room: RoomModel, users: [SenderModel], context: NSManagedObjectContext) {
        var currentTime = Date().addingTimeInterval(-3600) // 1시간 전부터 시작
        
        // 첫 번째 그룹 - 김철수의 연속 메시지
        let group1 = createChatGroup(sender: users[0], room: room, context: context)
        let messages1 = [
            "안녕하세요! 새로 입사한 김철수입니다.",
            "잘 부탁드립니다!",
            "혹시 점심 어디서 드시는지 알 수 있을까요?"
        ]
        
        for (index, content) in messages1.enumerated() {
            let message = createMessage(
                content: content,
                sender: users[0],
                room: room,
                time: currentTime.addingTimeInterval(TimeInterval(index * 30)),
                context: context
            )
            group1.addToChats(message)
        }
        group1.latestedAt = currentTime.addingTimeInterval(TimeInterval((messages1.count - 1) * 30))
        currentTime = currentTime.addingTimeInterval(TimeInterval(messages1.count * 30 + 120)) // 2분 후
        
        // 두 번째 그룹 - 이영희의 답변
        let group2 = createChatGroup(sender: users[1], room: room, context: context)
        let messages2 = [
            "안녕하세요! 반갑습니다 😊",
            "보통 회사 식당이나 근처 맛집에서 먹어요",
            "오늘 같이 드실래요?"
        ]
        
        for (index, content) in messages2.enumerated() {
            let message = createMessage(
                content: content,
                sender: users[1],
                room: room,
                time: currentTime.addingTimeInterval(TimeInterval(index * 45)),
                context: context
            )
            group2.addToChats(message)
        }
        group2.latestedAt = currentTime.addingTimeInterval(TimeInterval((messages2.count - 1) * 45))
        currentTime = currentTime.addingTimeInterval(TimeInterval(messages2.count * 45 + 60))
        
        // 세 번째 그룹 - 박민수 참여
        let group3 = createChatGroup(sender: users[2], room: room, context: context)
        let message3 = createMessage(
            content: "저도 함께해도 될까요? 신입분 환영합니다! 🎉",
            sender: users[2],
            room: room,
            time: currentTime,
            context: context
        )
        group3.addToChats(message3)
        group3.latestedAt = currentTime
        currentTime = currentTime.addingTimeInterval(180)
        
        // 네 번째 그룹 - 김철수의 감사 인사
        let group4 = createChatGroup(sender: users[0], room: room, context: context)
        let messages4 = [
            "와! 정말 감사합니다!",
            "12시에 만날까요?",
            "회사 1층 로비에서 만나요!"
        ]
        
        for (index, content) in messages4.enumerated() {
            let message = createMessage(
                content: content,
                sender: users[0],
                room: room,
                time: currentTime.addingTimeInterval(TimeInterval(index * 20)),
                context: context
            )
            group4.addToChats(message)
        }
        group4.latestedAt = currentTime.addingTimeInterval(TimeInterval((messages4.count - 1) * 20))
        
        room.addToChats(group1)
        room.addToChats(group2)
        room.addToChats(group3)
        room.addToChats(group4)
    }
    
    // MARK: - 개발팀 채팅방 메시지 생성
    private static func createDevTeamMessages(room: RoomModel, users: [SenderModel], context: NSManagedObjectContext) {
        var currentTime = Date().addingTimeInterval(-1800) // 30분 전부터
        
        // 기술 토론
        let group1 = createChatGroup(sender: users[0], room: room, context: context)
        let messages1 = [
            "이번 프로젝트에서 SwiftUI 사용하는 거 어떻게 생각하세요?",
            "Core Data 연동도 고려해야 할 것 같은데",
            "성능상 이슈는 없을까요?"
        ]
        
        for (index, content) in messages1.enumerated() {
            let message = createMessage(
                content: content,
                sender: users[0],
                room: room,
                time: currentTime.addingTimeInterval(TimeInterval(index * 40)),
                context: context
            )
            group1.addToChats(message)
        }
        group1.latestedAt = currentTime.addingTimeInterval(TimeInterval((messages1.count - 1) * 40))
        currentTime = currentTime.addingTimeInterval(TimeInterval(messages1.count * 40 + 90))
        
        // 기술 답변
        let group2 = createChatGroup(sender: users[1], room: room, context: context)
        let messages2 = [
            "SwiftUI 좋죠! iOS 15 이상 타겟이라면 문제없을 것 같아요",
            "Core Data는 @FetchRequest 사용하면 편해요",
            "제가 작년에 비슷한 프로젝트 해봤는데 성능 괜찮았어요"
        ]
        
        for (index, content) in messages2.enumerated() {
            let message = createMessage(
                content: content,
                sender: users[1],
                room: room,
                time: currentTime.addingTimeInterval(TimeInterval(index * 35)),
                context: context
            )
            group2.addToChats(message)
        }
        group2.latestedAt = currentTime.addingTimeInterval(TimeInterval((messages2.count - 1) * 35))
        
        room.addToChats(group1)
        room.addToChats(group2)
    }
    
    // MARK: - 디자인팀 채팅방 메시지 생성
    private static func createDesignTeamMessages(room: RoomModel, users: [SenderModel], context: NSManagedObjectContext) {
        var currentTime = Date().addingTimeInterval(-2400) // 40분 전부터
        
        let group1 = createChatGroup(sender: users[0], room: room, context: context)
        let messages1 = [
            "새 앱 아이콘 디자인 완료했어요!",
            "Figma에 업로드해둘게요",
            "피드백 부탁드려요 🎨"
        ]
        
        for (index, content) in messages1.enumerated() {
            let message = createMessage(
                content: content,
                sender: users[0],
                room: room,
                time: currentTime.addingTimeInterval(TimeInterval(index * 50)),
                context: context
            )
            group1.addToChats(message)
        }
        group1.latestedAt = currentTime.addingTimeInterval(TimeInterval((messages1.count - 1) * 50))
        
        room.addToChats(group1)
    }
    
    // MARK: - 프로젝트 채팅방 메시지 생성
    private static func createProjectMessages(room: RoomModel, users: [SenderModel], context: NSManagedObjectContext) {
        var currentTime = Date().addingTimeInterval(-7200) // 2시간 전부터
        
        let group1 = createChatGroup(sender: users[0], room: room, context: context)
        let messages1 = [
            "프로젝트 알파 킥오프 미팅 정리",
            "1. 개발 기간: 3개월",
            "2. 주요 기능: 실시간 채팅",
            "3. 기술 스택: SwiftUI + Core Data"
        ]
        
        for (index, content) in messages1.enumerated() {
            let message = createMessage(
                content: content,
                sender: users[0],
                room: room,
                time: currentTime.addingTimeInterval(TimeInterval(index * 60)),
                context: context
            )
            group1.addToChats(message)
        }
        group1.latestedAt = currentTime.addingTimeInterval(TimeInterval((messages1.count - 1) * 60))
        
        room.addToChats(group1)
    }
    
    // MARK: - 자유 대화방 메시지 생성
    private static func createRandomMessages(room: RoomModel, users: [SenderModel], context: NSManagedObjectContext) {
        var currentTime = Date().addingTimeInterval(-600) // 10분 전부터
        
        let randomMessages = [
            "오늘 날씨 정말 좋네요! ☀️",
            "점심 뭐 드셨어요?",
            "커피 한 잔 하고 싶어요 ☕",
            "주말에 영화 보러 갈 예정이에요",
            "새로운 카페 발견했어요!",
            "오늘 야근인가요? 😭",
            "내일 비 온다고 하네요",
            "새 폰 샀어요! 📱"
        ]
        
        for (index, user) in users.enumerated() {
            if index < randomMessages.count {
                let group = createChatGroup(sender: user, room: room, context: context)
                let message = createMessage(
                    content: randomMessages[index],
                    sender: user,
                    room: room,
                    time: currentTime.addingTimeInterval(TimeInterval(index * 90)),
                    context: context
                )
                group.addToChats(message)
                group.latestedAt = currentTime.addingTimeInterval(TimeInterval(index * 90))
                room.addToChats(group)
            }
        }
    }
    
    // MARK: - 헬퍼 메서드들
    
    private static func createChatGroup(sender: SenderModel, room: RoomModel, context: NSManagedObjectContext) -> ChatGroupModel {
        let group = ChatGroupModel(context: context)
        group.sender = sender
        return group
    }
    
    private static func createMessage(content: String, sender: SenderModel, room: RoomModel, time: Date, context: NSManagedObjectContext) -> ChatModel {
        let message = ChatModel(context: context)
        message.chatId = UUID().uuidString
        message.content = content
        message.createdAt = time
        message.updatedAt = time
        message.roomId = room.roomId
        message.sender = sender
        
        // 랜덤하게 일부 메시지에 파일 첨부 (10% 확률)
        if Int.random(in: 1...10) == 1 {
            let files = ["image_\(Int.random(in: 1...5)).jpg"]
            message.filesData = try? JSONEncoder().encode(files)
        }
        
        return message
    }
    
    private static func clearAllData(context: NSManagedObjectContext) {
        let entities = ["ChatModel", "ChatGroupModel", "RoomModel", "SenderModel"]
        
        for entityName in entities {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try context.execute(deleteRequest)
            } catch {
                print("Failed to delete \(entityName): \(error)")
            }
        }
    }
    
    private static func saveContext(_ context: NSManagedObjectContext) {
        do {
            try context.save()
            print("✅ 목 데이터 생성 완료!")
        } catch {
            print("❌ 목 데이터 저장 실패: \(error)")
        }
    }
}
