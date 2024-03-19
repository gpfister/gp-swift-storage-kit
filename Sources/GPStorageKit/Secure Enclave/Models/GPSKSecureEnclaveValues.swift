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

public class GPSKSecureEnclaveValues {
    public static let `default` = GPSKSecureEnclaveValues()

    var values: [String: Any] = [:]

    private let domain: String

    init(domain: String? = nil) {
        self.domain = domain ?? Bundle.main.bundleIdentifier!
    }

    public subscript<GPSKKey: GPSKSecureEnclaveKey>(
        _ SecureEnclaveKey: GPSKKey.Type
    ) -> GPSKKey.GPSKValue? {
        guard (SecureEnclaveKey.isLinkedToUserId && GPSKStorageService.shared.userId != nil) || !SecureEnclaveKey.isLinkedToUserId
        else { /* return userDefaultKey.defaultValue */ fatalError("[GPSKUserDefaultValues] No userId set") }
        let key = SecureEnclaveKey.isLinkedToUserId ? "user.\(GPSKStorageService.shared.userId ?? "").\(SecureEnclaveKey.key)" : SecureEnclaveKey.key
        let secKey: GPSKKey.GPSKValue? = try? getHandle(forKey: key)
        return secKey ?? SecureEnclaveKey.defaultValue
    }
}

// MARK: - Private

private extension GPSKSecureEnclaveValues {
    func getHandle<T: GPSKSecureEnclavePrivateKeyConvertible>(
        forKey key: String,
        requiresBiometry: Bool = false
    ) throws -> T? {
        if let secKey = try getHandle(forKey: key) {
            var error: Unmanaged<CFError>?
            guard let data = SecKeyCopyExternalRepresentation(secKey, &error) as Data? else {
                throw GPSKKeychainError.unableToParseSecKeyRepresentation(error.debugDescription)
            }
            do {
                let key = try T(dataRepresentation: data)
                return key
            } catch {
                throw GPSKKeychainError.unableToParseSecKeyRepresentation(error.localizedDescription)
            }
        } else {
            try generateKey(forKey: key, requiresBiometry: requiresBiometry)
            return try getHandle(forKey: key, requiresBiometry: requiresBiometry)
        }
    }

    private func generateKey(forKey key: String, requiresBiometry: Bool = false) throws {
        let flags: SecAccessControlCreateFlags = requiresBiometry ? [.privateKeyUsage, .biometryCurrentSet] : [.privateKeyUsage]

        let access = SecAccessControlCreateWithFlags(kCFAllocatorDefault,
                                                     kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                                                     flags,
                                                     nil)!

        let tag = "\(domain).\(key)".data(using: .utf8)!

        let privateKeyAttributes = [
            kSecAttrIsPermanent: true,
            kSecAttrApplicationTag: tag,
            kSecAttrAccessControl: access,
        ] as [String: Any]

        let attributes = [
            kSecAttrKeyType: kSecAttrKeyTypeEC,
            kSecAttrKeySizeInBits: 256,
            kSecAttrTokenID: kSecAttrTokenIDSecureEnclave,
            kSecPrivateKeyAttrs: privateKeyAttributes,
        ] as [String: Any]

        var error: Unmanaged<CFError>?
        guard let _ = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            throw GPSKSecureEnclaveError.unableToWrite("\((error!.takeRetainedValue() as Error).localizedDescription)")
        }
    }

    private func getHandle(forKey key: String) throws -> SecKey? {
        let tag = "\(domain).\(key)".data(using: .utf8)!

        let query = [
            kSecClass: kSecClassKey,
            kSecAttrApplicationTag: tag,
            kSecAttrKeyType: kSecAttrKeyTypeEC,
            kSecReturnRef: true,
        ] as [String: Any]

        var item: CFTypeRef?

        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess else {
            return nil
        }
        return (item as! SecKey)
    }

    private func deleteKey(forKey key: String) throws {
        let tag = "\(domain).\(key)".data(using: .utf8)!

        let query = [
            kSecClass: kSecClassKey,
            kSecAttrApplicationTag: tag,
            kSecAttrKeyType: kSecAttrKeyTypeEC,
            kSecReturnRef: true,
        ] as [String: Any]

        // Add the key to the keychain.
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess else {
            throw GPSKSecureEnclaveError.unableToDelete(status.message)
        }
    }
}
