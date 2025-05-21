//
//  KeychainManager.swift
//  Filtee
//
//  Created by 김도형 on 5/16/25.
//

import Foundation

final class KeychainManager: Sendable {
    private let service: String = "Filtee"
    
    static let shared = KeychainManager()
    
    private init() { }
    
    func save(_ data: String, key: Key) {
        guard read(key) == nil else {
            update(data.data(using: .utf8), key: key)
            return
        }
        create(data.data(using: .utf8), key: key)
    }

    // MARK: Read Item
    func read(_ key: Key) -> String? {
        let query: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: key.rawValue,
            kSecMatchLimit: kSecMatchLimitOne,
            kSecReturnData: true
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query, &result)
        guard status != errSecItemNotFound else {
            print("🗝️ '\(key)' 항목을 찾을 수 없어요.")
            return nil
        }
        guard status == errSecSuccess else { return nil }
        print("🗝️ '\(key)' 성공!")
        guard let result = result as? Data else { return nil }
        return String(data: result, encoding: .utf8)
    }

    // MARK: Delete Item

    public func delete(_ key: Key) {
        let query: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: key.rawValue
        ]

        let status = SecItemDelete(query)
        guard status != errSecItemNotFound else {
            print("🗝️ '\(key)' 항목을 찾을 수 없어요.")
            return
        }
        guard status == errSecSuccess else { return }
        print("🗝️ '\(key)' 성공!")
    }
    
    private func create(_ data: Data?, key: Key) {
        guard let data = data else {
            print("🗝️ '\(key)' 값이 없어요.")
            return
        }

        let query: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: key.rawValue,
            kSecValueData: data
        ]

        let status = SecItemAdd(query, nil)
        guard status == errSecSuccess else {
            print("🗝️ '\(key)' 상태 = \(status)")
            return
        }
        print("🗝️ '\(key)' 성공!")
    }
    
    // MARK: Update Item
    private func update(_ data: Data?, key: Key) {
        guard let data = data else {
            print("🗝️ '\(key)' 값이 없어요.")
            return
        }

        let query: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: key.rawValue
        ]
        let attributes: NSDictionary = [
            kSecValueData: data
        ]

        let status = SecItemUpdate(query, attributes)
        guard status == errSecSuccess else {
            print("🗝️ '\(key)' 상태 = \(status)")
            return
        }
        print("🗝️ '\(key)' 성공!")
    }
}

extension KeychainManager {
    enum Key: String {
        case accessToken
        case refreshToken
        case appleRefreshToken
        case appleAuthorizationCode
    }
}
