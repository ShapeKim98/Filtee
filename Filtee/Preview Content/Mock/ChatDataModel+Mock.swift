//
//  ChatDataModel+Mock.swift
//  Filtee
//
//  Created by 김도형 on 6/18/25.
//

import Foundation
import CoreData

// MARK: - 🎯 대용량 채팅 데이터 목업 생성기
struct MockDataGenerator {
    
    // MARK: - 메인 생성 메서드
    static func createMockData(context: NSManagedObjectContext, chatGroupsPerRoom: Int = 500) {
        print("🚀 목 데이터 생성 시작...")
        
        // 기존 데이터 삭제 (선택사항)
        clearAllData(context: context)
        
        // 1. 사용자 생성 (더 많은 사용자)
        let users = createUsers(context: context)
        print("👥 사용자 \(users.count)명 생성 완료")
        
        // 2. 채팅방 생성
        let rooms = createRooms(context: context)
        print("🏠 채팅방 \(rooms.count)개 생성 완료")
        
        // 3. 채팅방에 참여자 추가
        assignParticipantsToRooms(rooms: rooms, users: users)
        print("🤝 참여자 할당 완료")
        
        // 4. 대용량 메시지 및 그룹 생성
        for (index, room) in rooms.enumerated() {
            print("💬 \(room.roomId ?? "unknown") 채팅방 데이터 생성 중... (\(index + 1)/\(rooms.count))")
            createMassiveMessagesAndGroups(
                room: room,
                users: users,
                targetGroupCount: chatGroupsPerRoom,
                context: context
            )
        }
        
        // 저장
        saveContext(context)
        print("✅ 총 \(rooms.count)개 방, 각각 약 \(chatGroupsPerRoom)개 그룹 생성 완료!")
    }
    
    // MARK: - 확장된 사용자 생성 (20명)
    private static func createUsers(context: NSManagedObjectContext) -> [SenderDataModel] {
        let userData = [
            ("user001", "김철수", "https://picsum.photos/100/100?random=1"),
            ("user002", "이영희", "https://picsum.photos/100/100?random=2"),
            ("user003", "박민수", "https://picsum.photos/100/100?random=3"),
            ("user004", "최지혜", "https://picsum.photos/100/100?random=4"),
            ("user005", "정호준", "https://picsum.photos/100/100?random=5"),
            ("user006", "윤서아", "https://picsum.photos/100/100?random=6"),
            ("user007", "김도현", "https://picsum.photos/100/100?random=7"),
            ("user008", "이수민", "https://picsum.photos/100/100?random=8"),
            ("user009", "장현우", "https://picsum.photos/100/100?random=9"),
            ("user010", "한소영", "https://picsum.photos/100/100?random=10"),
            ("user011", "오준호", "https://picsum.photos/100/100?random=11"),
            ("user012", "신예린", "https://picsum.photos/100/100?random=12"),
            ("user013", "류태현", "https://picsum.photos/100/100?random=13"),
            ("user014", "강민정", "https://picsum.photos/100/100?random=14"),
            ("user015", "조성훈", "https://picsum.photos/100/100?random=15"),
            ("user016", "배하늘", nil), // 프로필 없음
            ("user017", "임재원", "https://picsum.photos/100/100?random=17"),
            ("user018", "문지현", nil), // 프로필 없음
            ("user019", "황민석", "https://picsum.photos/100/100?random=19"),
            ("user020", "노지우", "https://picsum.photos/100/100?random=20"),
        ]
        
        var users: [SenderDataModel] = []
        
        for (userId, nick, profileImage) in userData {
            let user = SenderDataModel(context: context)
            user.userId = userId
            user.nick = nick
            user.profileImage = profileImage
            users.append(user)
        }
        
        return users
    }
    
    // MARK: - 채팅방 생성
    private static func createRooms(context: NSManagedObjectContext) -> [RoomDataModel] {
        let roomData = [
            ("general", "일반 채팅방"),
            ("dev_team", "개발팀 채팅방"),
            ("design_team", "디자인팀 채팅방"),
            ("project_alpha", "프로젝트 알파"),
            ("random_chat", "자유 대화방"),
            ("announcement", "공지사항"),
            ("help_desk", "헬프데스크"),
            ("social", "소셜 채팅"),
        ]
        
        var rooms: [RoomDataModel] = []
        
        for (roomId, _) in roomData {
            let room = RoomDataModel(context: context)
            room.roomId = roomId
            room.createdAt = Date().addingTimeInterval(-Double.random(in: 86400*7...86400*30)) // 1주-1달 전
            room.updatedAt = Date()
            rooms.append(room)
        }
        
        return rooms
    }
    
    // MARK: - 채팅방 참여자 할당
    private static func assignParticipantsToRooms(rooms: [RoomDataModel], users: [SenderDataModel]) {
        for room in rooms {
            let participantCount = Int.random(in: 5...15) // 방마다 5~15명 참여
            let participants = users.shuffled().prefix(participantCount)
            
            for user in participants {
                room.addToParticipants(user)
            }
        }
    }
    
    // MARK: - 🚀 실제 채팅앱 방식의 메시지 및 그룹 생성
    private static func createMassiveMessagesAndGroups(
        room: RoomDataModel,
        users: [SenderDataModel],
        targetGroupCount: Int,
        context: NSManagedObjectContext
    ) {
        guard let roomParticipants = room.participants?.allObjects as? [SenderDataModel],
              !roomParticipants.isEmpty else { return }
        
        // 시간 설정: 30일 전부터 현재까지
        let startTime = Date().addingTimeInterval(-30 * 24 * 3600) // 30일 전
        let endTime = Date()
        
        var currentTime = startTime
        var currentGroup: ChatGroupDataModel?
        var lastSender: SenderDataModel?
        var lastMinute: Int?
        var createdGroups = 0
        var totalMessages = 0
        
        // 메시지 스트림 생성 (더 자연스러운 방식)
        while createdGroups < targetGroupCount && currentTime < endTime {
            // 다음 메시지 시간 결정
            let timeGap = generateRealisticTimeGap()
            currentTime = currentTime.addingTimeInterval(timeGap)
            
            if currentTime >= endTime { break }
            
            // 발신자 결정 (가중치 적용 - 최근 발신자가 연속으로 보낼 확률 높임)
            let sender = chooseSender(
                participants: roomParticipants,
                lastSender: lastSender,
                lastMessageTime: currentTime
            )
            
            // 현재 분 계산
            let calendar = Calendar.current
            let currentMinute = calendar.component(.minute, from: currentTime)
            let currentHour = calendar.component(.hour, from: currentTime)
            let currentDay = calendar.component(.day, from: currentTime)
            let timeKey = "\(currentDay)-\(currentHour)-\(currentMinute)"
            
            // ChatGroup 생성 조건 확인
            let shouldCreateNewGroup = shouldCreateNewChatGroup(
                currentSender: sender,
                lastSender: lastSender,
                currentTime: currentTime,
                lastGroup: currentGroup
            )
            
            if shouldCreateNewGroup {
                // 새로운 ChatGroup 생성
                currentGroup = createChatGroup(sender: sender, room: room, context: context)
                room.addToChats(currentGroup!)
                createdGroups += 1
                
                if createdGroups % 100 == 0 {
                    try? context.save()
                    print("  📊 \(createdGroups)/\(targetGroupCount) 그룹 생성 완료")
                }
            }
            
            // 현재 그룹에 메시지 추가 (연속 메시지 패턴 고려)
            let messagesToAdd = generateContinuousMessages(
                sender: sender,
                room: room,
                startTime: currentTime,
                isNewGroup: shouldCreateNewGroup,
                context: context
            )
            
            for message in messagesToAdd {
                currentGroup?.addToChats(message)
                totalMessages += 1
            }
            
            // 그룹의 최신 시간 업데이트
            if let lastMessage = messagesToAdd.last {
                currentGroup?.latestedAt = lastMessage.createdAt ?? currentTime
                currentTime = lastMessage.createdAt ?? currentTime
            }
            
            // 상태 업데이트
            lastSender = sender
            lastMinute = currentMinute
        }
        
        print("  ✅ \(room.roomId ?? "unknown") 방: \(createdGroups)개 그룹, \(totalMessages)개 메시지 생성 완료")
    }
    
    // MARK: - 🔄 ChatGroup 생성 조건 확인
    private static func shouldCreateNewChatGroup(
        currentSender: SenderDataModel,
        lastSender: SenderDataModel?,
        currentTime: Date,
        lastGroup: ChatGroupDataModel?
    ) -> Bool {
        // 첫 번째 그룹인 경우
        guard let lastSender = lastSender,
              let lastGroup = lastGroup,
              let lastMessageTime = lastGroup.latestedAt else {
            return true
        }
        
        // 발신자가 다른 경우
        if currentSender.objectID != lastSender.objectID {
            return true
        }
        
        // 시간의 분이 다른 경우
        let calendar = Calendar.current
        let lastMinute = calendar.component(.minute, from: lastMessageTime)
        let currentMinute = calendar.component(.minute, from: currentTime)
        let lastHour = calendar.component(.hour, from: lastMessageTime)
        let currentHour = calendar.component(.hour, from: currentTime)
        let lastDay = calendar.component(.day, from: lastMessageTime)
        let currentDay = calendar.component(.day, from: currentTime)
        
        // 다른 일, 시, 분이면 새 그룹
        if lastDay != currentDay || lastHour != currentHour || lastMinute != currentMinute {
            return true
        }
        
        // 같은 발신자, 같은 분이지만 너무 긴 시간 간격 (5분 이상)
        let timeDifference = currentTime.timeIntervalSince(lastMessageTime)
        if timeDifference > 300 { // 5분
            return true
        }
        
        return false
    }
    
    // MARK: - 👤 발신자 선택 (가중치 적용)
    private static func chooseSender(
        participants: [SenderDataModel],
        lastSender: SenderDataModel?,
        lastMessageTime: Date
    ) -> SenderDataModel {
        guard let lastSender = lastSender else {
            return participants.randomElement()!
        }
        
        // 연속 메시지 확률 (같은 사용자가 계속 보낼 확률)
        let continuationProbability: Double = 0.4 // 40%
        
        if Double.random(in: 0...1) < continuationProbability {
            return lastSender
        } else {
            // 다른 사용자 선택 (마지막 발신자 제외)
            let otherParticipants = participants.filter { $0.objectID != lastSender.objectID }
            return otherParticipants.randomElement() ?? participants.randomElement()!
        }
    }
    
    // MARK: - 💬 연속 메시지 생성
    private static func generateContinuousMessages(
        sender: SenderDataModel,
        room: RoomDataModel,
        startTime: Date,
        isNewGroup: Bool,
        context: NSManagedObjectContext
    ) -> [ChatDataModel] {
        
        // 새 그룹이면 더 많은 메시지, 기존 그룹이면 적은 메시지
        let messageCount: Int
        if isNewGroup {
            // 새 그룹: 1-5개 메시지
            messageCount = Int.random(in: 1...5)
        } else {
            // 기존 그룹에 추가: 1-2개 메시지 (연속성 고려)
            messageCount = Int.random(in: 1...2)
        }
        
        var messages: [ChatDataModel] = []
        var currentTime = startTime
        
        for i in 0..<messageCount {
            let content = generateSmartMessage(
                sender: sender,
                room: room,
                messageIndex: i,
                totalMessages: messageCount,
                isNewGroup: isNewGroup
            )
            
            let message = createMessage(
                content: content,
                sender: sender,
                room: room,
                time: currentTime,
                context: context
            )
            
            messages.append(message)
            
            // 같은 그룹 내 메시지 간격 (5초~30초)
            if i < messageCount - 1 {
                let gap = TimeInterval.random(in: 5...30)
                currentTime = currentTime.addingTimeInterval(gap)
            }
        }
        
        return messages
    }
    
    // MARK: - 🧠 스마트 메시지 생성
    private static func generateSmartMessage(
        sender: SenderDataModel,
        room: RoomDataModel,
        messageIndex: Int,
        totalMessages: Int,
        isNewGroup: Bool
    ) -> String {
        
        let roomType = room.roomId ?? "general"
        let senderName = sender.nick ?? "Unknown"
        
        // 첫 메시지와 연속 메시지 구분
        if isNewGroup && messageIndex == 0 {
            // 새 그룹의 첫 메시지 (주제 시작)
            return generateTopicStarterMessage(roomType: roomType, senderName: senderName)
        } else {
            // 연속 메시지 또는 응답
            return generateFollowUpMessage(
                roomType: roomType,
                messageIndex: messageIndex,
                totalMessages: totalMessages
            )
        }
    }
    
    // MARK: - 🎯 주제 시작 메시지
    private static func generateTopicStarterMessage(roomType: String, senderName: String) -> String {
        let starters: [String: [String]] = [
            "general": [
                "안녕하세요!", "좋은 아침입니다", "수고하세요", "혹시 시간 되시나요?",
                "궁금한 게 있어서요", "공지사항 확인하셨나요?", "오늘 일정 어떻게 되나요?",
                "점심 같이 드실 분?", "커피 마시러 가실래요?", "날씨가 좋네요"
            ],
            "dev_team": [
                "코드 리뷰 요청드립니다", "버그 리포트 공유합니다", "배포 준비 완료됐어요",
                "API 문서 업데이트했습니다", "테스트 결과 나왔어요", "성능 이슈 발견했습니다",
                "새로운 라이브러리 제안드려요", "CI/CD 파이프라인 수정했어요", "코드 커버리지 개선했습니다"
            ],
            "design_team": [
                "디자인 시안 완성했어요", "사용자 피드백 정리했습니다", "프로토타입 업데이트했어요",
                "색상 가이드라인 제안드려요", "아이콘 세트 완성했습니다", "와이어프레임 공유드려요",
                "사용성 테스트 결과에요", "브랜딩 가이드 수정했어요"
            ],
            "project_alpha": [
                "프로젝트 진행 상황 공유", "마일스톤 업데이트", "일정 조정 제안",
                "리스크 관리 보고서", "품질 검토 완료", "스프린트 회고",
                "백로그 우선순위 조정", "팀 리소스 현황"
            ]
        ]
        
        let messages = starters[roomType] ?? starters["general"]!
        return messages.randomElement()!
    }
    
    // MARK: - 📝 후속 메시지
    private static func generateFollowUpMessage(
        roomType: String,
        messageIndex: Int,
        totalMessages: Int
    ) -> String {
        
        // 메시지 위치에 따른 패턴
        if messageIndex == totalMessages - 1 && totalMessages > 1 {
            // 마지막 메시지 (마무리)
            return ["감사합니다", "확인했습니다", "좋아요!", "알겠어요", "네네", "👍"].randomElement()!
        }
        
        // 중간 메시지들
        let followUps: [String: [String]] = [
            "general": [
                "네 맞아요", "그렇네요", "좋은 생각이에요", "동의합니다", "저도 그렇게 생각해요",
                "혹시 더 자세히 알 수 있을까요?", "언제 시간 되시나요?", "어떻게 진행할까요?"
            ],
            "dev_team": [
                "코드 확인해보겠습니다", "테스트 케이스 추가할게요", "문서 업데이트 필요해요",
                "성능 측정해봤는데", "메모리 사용량이", "버그 재현했어요",
                "솔루션 제안드려요", "리팩토링이 필요할 것 같아요"
            ],
            "design_team": [
                "사용자 경험을 고려하면", "접근성도 체크해야겠어요", "반응형으로 수정할게요",
                "A/B 테스트 해볼까요?", "피그마 링크 공유할게요", "프로토타입으로 만들어볼게요"
            ],
            "project_alpha": [
                "일정 검토가 필요해요", "리소스 할당을 다시", "우선순위를 조정하면",
                "위험 요소를 고려해서", "품질 기준에 맞춰", "다음 스프린트에"
            ]
        ]
        
        let messages = followUps[roomType] ?? followUps["general"]!
        return messages.randomElement()!
    }
    
    // MARK: - 메시지 패턴 enum
    enum MessagePattern: CaseIterable {
        case single          // 단일 메시지
        case shortBurst      // 짧은 연속 메시지 (2-3개)
        case conversation    // 대화형 (4-6개)
        case longThread      // 긴 스레드 (7-12개)
        
        static func random() -> MessagePattern {
            let weights: [MessagePattern: Int] = [
                .single: 40,        // 40% 확률
                .shortBurst: 30,    // 30% 확률
                .conversation: 20,  // 20% 확률
                .longThread: 10     // 10% 확률
            ]
            
            let totalWeight = weights.values.reduce(0, +)
            let randomValue = Int.random(in: 1...totalWeight)
            
            var currentWeight = 0
            for (pattern, weight) in weights {
                currentWeight += weight
                if randomValue <= currentWeight {
                    return pattern
                }
            }
            
            return .single
        }
    }
    
    // MARK: - 패턴별 메시지 생성
    private static func generateMessagesForPattern(
        pattern: MessagePattern,
        sender: SenderDataModel,
        room: RoomDataModel,
        startTime: Date,
        context: NSManagedObjectContext
    ) -> [ChatDataModel] {
        
        let messageCount: Int
        let timeGapRange: ClosedRange<TimeInterval>
        
        switch pattern {
        case .single:
            messageCount = 1
            timeGapRange = 0...0
        case .shortBurst:
            messageCount = Int.random(in: 2...3)
            timeGapRange = 5...30 // 5-30초 간격
        case .conversation:
            messageCount = Int.random(in: 4...6)
            timeGapRange = 10...60 // 10초-1분 간격
        case .longThread:
            messageCount = Int.random(in: 7...12)
            timeGapRange = 15...120 // 15초-2분 간격
        }
        
        var messages: [ChatDataModel] = []
        var currentTime = startTime
        
        for i in 0..<messageCount {
            let content = generateRealisticMessage(
                sender: sender,
                room: room,
                messageIndex: i,
                totalMessages: messageCount,
                pattern: pattern
            )
            
            let message = createMessage(
                content: content,
                sender: sender,
                room: room,
                time: currentTime,
                context: context
            )
            
            messages.append(message)
            
            // 다음 메시지까지의 간격
            if i < messageCount - 1 {
                let timeGap = TimeInterval.random(in: timeGapRange)
                currentTime = currentTime.addingTimeInterval(timeGap)
            }
        }
        
        return messages
    }
    
    // MARK: - 현실적인 메시지 내용 생성
    private static func generateRealisticMessage(
        sender: SenderDataModel,
        room: RoomDataModel,
        messageIndex: Int,
        totalMessages: Int,
        pattern: MessagePattern
    ) -> String {
        
        let roomType = room.roomId ?? "general"
        
        // 방 타입별 메시지 풀
        let messagePools: [String: [String]] = [
            "general": [
                "안녕하세요!", "좋은 하루 되세요", "수고하세요", "감사합니다",
                "네 알겠습니다", "확인했습니다", "좋은 아이디어네요", "동의합니다",
                "궁금한 점이 있어서요", "도움이 필요해요", "시간 되실 때 연락주세요",
                "오늘 날씨가 좋네요", "점심 맛있게 드세요", "주말 잘 보내세요"
            ],
            "dev_team": [
                "코드 리뷰 부탁드립니다", "버그 발견했습니다", "테스트 완료했어요",
                "배포 준비됐나요?", "API 문서 확인해주세요", "데이터베이스 마이그레이션 필요해요",
                "Swift 6 업데이트 어떠세요?", "CoreData 이슈 해결했어요", "성능 최적화 필요할 것 같아요",
                "CI/CD 파이프라인 설정했어요", "코드 커버리지 올렸습니다", "메모리 누수 수정했어요"
            ],
            "design_team": [
                "디자인 시안 업데이트했어요", "사용자 경험 개선안이에요", "색상 팔레트 변경했습니다",
                "프로토타입 완성했어요", "아이콘 디자인 어떠세요?", "와이어프레임 공유드려요",
                "폰트 변경 제안드려요", "애니메이션 효과 추가했어요", "반응형 디자인 적용했습니다",
                "브랜딩 가이드라인 업데이트", "A/B 테스트 결과 나왔어요"
            ],
            "project_alpha": [
                "프로젝트 진행 상황 공유", "마일스톤 달성했어요", "일정 조정이 필요해요",
                "리소스 할당 논의해요", "위험 요소 발견했어요", "품질 검토 완료",
                "스프린트 계획 세웠어요", "백로그 정리했습니다", "회고 미팅 언제 할까요?",
                "데모 준비됐어요", "릴리즈 노트 작성했어요"
            ]
        ]
        
        let defaultMessages = [
            "네", "좋아요", "확인", "알겠습니다", "감사해요", "수고하세요",
            "👍", "😊", "ㅋㅋ", "ㅎㅎ", "오케이", "굿!", "완료", "처리했어요"
        ]
        
        let relevantMessages = messagePools[roomType] ?? defaultMessages
        
        // 패턴에 따른 메시지 선택
        if pattern == .conversation && totalMessages > 1 {
            if messageIndex == 0 {
                // 대화 시작
                return relevantMessages.randomElement() ?? "안녕하세요"
            } else if messageIndex == totalMessages - 1 {
                // 대화 마무리
                return ["감사합니다", "알겠습니다", "좋아요", "확인했어요", "네네"].randomElement()!
            }
        }
        
        // 이모지 추가 확률 (20%)
        var message = relevantMessages.randomElement() ?? "메시지"
        if Int.random(in: 1...5) == 1 {
            let emojis = ["😊", "👍", "💪", "🎉", "✅", "🔥", "💯", "👏", "😎", "🚀"]
            message += " " + emojis.randomElement()!
        }
        
        return message
    }
    
    // MARK: - 현실적인 시간 간격 생성
    private static func generateRealisticTimeGap() -> TimeInterval {
        // 현실적인 채팅 패턴: 대부분 짧은 간격, 가끔 긴 간격
        let random = Double.random(in: 0...1)
        
        switch random {
        case 0.0..<0.5:     // 50% - 1분~10분
            return TimeInterval.random(in: 60...600)
        case 0.5..<0.8:     // 30% - 10분~1시간
            return TimeInterval.random(in: 600...3600)
        case 0.8..<0.95:    // 15% - 1시간~6시간
            return TimeInterval.random(in: 3600...21600)
        default:            // 5% - 6시간~24시간
            return TimeInterval.random(in: 21600...86400)
        }
    }
    
    // MARK: - 헬퍼 메서드들
    
    private static func createChatGroup(sender: SenderDataModel, room: RoomDataModel, context: NSManagedObjectContext) -> ChatGroupDataModel {
        let group = ChatGroupDataModel(context: context)
        group.room = room
        group.sender = sender
        return group
    }
    
    private static func createMessage(content: String, sender: SenderDataModel, room: RoomDataModel, time: Date, context: NSManagedObjectContext) -> ChatDataModel {
        let message = ChatDataModel(context: context)
        message.chatId = UUID().uuidString
        message.content = content
        message.createdAt = time
        message.updatedAt = time
        message.roomId = room.roomId
        message.sender = sender
        
        // 랜덤하게 일부 메시지에 파일 첨부 (5% 확률)
        if Int.random(in: 1...20) == 1 {
            let fileTypes = ["image_\(Int.random(in: 1...10)).jpg", "document_\(Int.random(in: 1...5)).pdf", "video_\(Int.random(in: 1...3)).mp4"]
            message.filesData = try? JSONEncoder().encode([fileTypes.randomElement()!])
        }
        
        return message
    }
    
    private static func clearAllData(context: NSManagedObjectContext) {
        let entities = ["ChatDataModel", "ChatGroupDataModel", "RoomDataModel", "SenderDataModel"]
        
        for entityName in entities {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try context.execute(deleteRequest)
                try context.save() // 즉시 저장
            } catch {
                print("Failed to delete \(entityName): \(error)")
            }
        }
    }
    
    private static func saveContext(_ context: NSManagedObjectContext) {
        do {
            try context.save()
            print("✅ 목 데이터 저장 완료!")
        } catch {
            print("❌ 목 데이터 저장 실패: \(error)")
        }
    }
}

// MARK: - 🎯 사용 예시 및 설정
extension MockDataGenerator {
    
    /// 빠른 테스트용 (방당 50개 그룹)
    static func createTestData(context: NSManagedObjectContext) {
        createMockData(context: context, chatGroupsPerRoom: 50)
    }
    
    /// 중간 규모 (방당 200개 그룹)
    static func createMediumData(context: NSManagedObjectContext) {
        createMockData(context: context, chatGroupsPerRoom: 200)
    }
    
    /// 대용량 (방당 1000개 그룹)
    static func createLargeData(context: NSManagedObjectContext) {
        createMockData(context: context, chatGroupsPerRoom: 1000)
    }
    
    /// 극대용량 (방당 5000개 그룹) - 페이지네이션 스트레스 테스트용
    static func createMassiveData(context: NSManagedObjectContext) {
        createMockData(context: context, chatGroupsPerRoom: 5000)
    }
}

// MARK: - 📊 데이터 분석 헬퍼
struct MockDataAnalyzer {
    
    static func analyzeGeneratedData(context: NSManagedObjectContext) {
        let roomRequest: NSFetchRequest<RoomDataModel> = RoomDataModel.fetchRequest()
        let groupRequest: NSFetchRequest<ChatGroupDataModel> = ChatGroupDataModel.fetchRequest()
        let messageRequest: NSFetchRequest<ChatDataModel> = ChatDataModel.fetchRequest()
        
        do {
            let roomCount = try context.count(for: roomRequest)
            let groupCount = try context.count(for: groupRequest)
            let messageCount = try context.count(for: messageRequest)
            
            print("📊 생성된 데이터 분석:")
            print("  🏠 채팅방: \(roomCount)개")
            print("  📦 채팅그룹: \(groupCount)개 (평균 \(groupCount/max(roomCount,1))개/방)")
            print("  💬 메시지: \(messageCount)개 (평균 \(messageCount/max(groupCount,1))개/그룹)")
            
            // 방별 상세 분석
            let rooms = try context.fetch(roomRequest)
            for room in rooms {
                let roomGroupCount = room.chats?.count ?? 0
                print("    📍 \(room.roomId ?? "unknown"): \(roomGroupCount)개 그룹")
            }
            
        } catch {
            print("❌ 데이터 분석 실패: \(error)")
        }
    }
}
