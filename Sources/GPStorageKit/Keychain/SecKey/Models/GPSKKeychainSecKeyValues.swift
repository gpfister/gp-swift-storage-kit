//
// gp-swift-storage-kit
// Copyright (c) 2022-2024, Greg PFISTER. MIT License
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the “Software”), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
// the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import Combine
import CryptoKit
import Foundation

public class GPSKKeychainSecKeyValues {
    public static let `default` = GPSKKeychainSecKeyValues()

    var values: [String: Any] = [:]

    private let domain: String

    init(domain: String? = nil) {
        self.domain = domain ?? Bundle.main.bundleIdentifier!
    }

    public subscript<GPSKKey: GPSKKeychainSecKeyKey>(
        _ keychainSecKeyKey: GPSKKey.Type
    ) -> GPSKKey.GPSKValue? {
        get {
            guard (keychainSecKeyKey.isLinkedToUserId && GPSKStorageService.shared.userId != nil) || !keychainSecKeyKey.isLinkedToUserId
            else { /* return userDefaultKey.defaultValue */ fatalError("[GPSKUserDefaultValues] No userId set") }
            let key = keychainSecKeyKey.isLinkedToUserId ? "user.\(GPSKStorageService.shared.userId ?? "").\(keychainSecKeyKey.key)" : keychainSecKeyKey.key
            let secKey: GPSKKey.GPSKValue? = try? read(forKey: key)
            return secKey ?? keychainSecKeyKey.defaultValue
        }
        set {
            guard (keychainSecKeyKey.isLinkedToUserId && GPSKStorageService.shared.userId != nil) || !keychainSecKeyKey.isLinkedToUserId
            else { /* return userDefaultKey.defaultValue */ fatalError("[GPSKUserDefaultValues] No userId set") }
            let key = keychainSecKeyKey.isLinkedToUserId ? "user.\(GPSKStorageService.shared.userId ?? "").\(keychainSecKeyKey.key)" : keychainSecKeyKey.key
            if let newValue {
                try? store(newValue, forKey: key)
            } else {
                try? delete(forKey: key)
            }
        }
    }
}

// MARK: - Private

private extension GPSKKeychainSecKeyValues {
    func read<T: GPSKKeychainSecKeyConvertible>(forKey key: String) throws -> T? {
        // Stop here if no key was found
        guard let secKey: SecKey = try readSecKey(forKey: key) else {
            return nil
        }

        // Convert the SecKey into a CryptoKit key.
        var error: Unmanaged<CFError>?
        guard let data = SecKeyCopyExternalRepresentation(secKey, &error) as Data? else {
            throw GPSKKeychainError.unableToParseKeyRepresentation(error: (error!.takeRetainedValue()) as Error)
        }
        do {
            let key = try T(x963Representation: data)
            return key
        } catch {
            throw GPSKKeychainError.unableToParseKeyRepresentation(error: error)
        }
    }

    func store(_ secKey: (some GPSKKeychainSecKeyConvertible), forKey key: String) throws {
        if (try? readSecKey(forKey: key)) != nil {
            try delete(forKey: key)
        }
        
        // Describe the key
        let attributes = [kSecAttrKeyType: kSecAttrKeyTypeECSECPrimeRandom,
                         kSecAttrKeyClass: kSecAttrKeyClassPrivate] as [String: Any]
        
        // Get a SecKey representation.
        var error: Unmanaged<CFError>?
        guard let secKey = SecKeyCreateWithData(secKey.x963Representation as CFData,
                                                attributes as CFDictionary,
                                                &error)
        else {
            throw GPSKKeychainError.unableToCreateKeyRepresentation(error: (error!.takeRetainedValue()) as Error)
        }
        
        try storeSecKey(secKey, forKey: key)
    }
    
    func readSecKey(forKey key: String) throws -> SecKey? {
        let query = [kSecClass: kSecClassKey,
      kSecAttrApplicationLabel: "\(domain).\(key)",
               kSecAttrKeyType: kSecAttrKeyTypeECSECPrimeRandom,
 kSecUseDataProtectionKeychain: true,
                 kSecReturnRef: true] as [String: Any]
        
        // Find and cast the result as a SecKey instance.
        var item: CFTypeRef?
        var secKey: SecKey
        
        switch SecItemCopyMatching(query as CFDictionary, &item) {
        case errSecSuccess: secKey = item as! SecKey
        case errSecItemNotFound: return nil
        case let status: throw GPSKKeychainError.unableToRead(message: status.message)
        }
        
        return secKey
    }

    func storeSecKey(_ secKey: SecKey, forKey key: String) throws {
        // Describe the add operation.
        let query = [kSecClass: kSecClassKey,
                     kSecAttrApplicationLabel: "\(domain).\(key)",
                     kSecAttrAccessible: kSecAttrAccessibleWhenUnlocked,
                     kSecUseDataProtectionKeychain: true,
                     kSecValueRef: secKey] as [String: Any]

        // Add the key to the keychain.
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw GPSKKeychainError.unableToWrite(message: status.message)
        }
    }

    func delete(forKey key: String) throws {
        // Describe the add operation.
        let query = [kSecClass: kSecClassKey,
                     kSecAttrApplicationLabel: "\(domain).\(key)",
                     kSecAttrAccessible: kSecAttrAccessibleWhenUnlocked,
                     kSecUseDataProtectionKeychain: true] as [String: Any]

        // Add the key to the keychain.
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess else {
            throw GPSKKeychainError.unableToDelete(message: status.message)
        }
    }
}
