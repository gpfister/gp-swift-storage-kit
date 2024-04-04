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

public class GPSKKeychainDataValues {
    public static let `default` = GPSKKeychainDataValues()

    var values: [String: Any] = [:]

    private let domain: String

    init(domain: String? = nil) {
        self.domain = domain ?? Bundle.main.bundleIdentifier!
    }

    public subscript<GPSKKey: GPSKKeychainDataKey>(
        _ keychainDataKey: GPSKKey.Type
    ) -> GPSKKey.GPSKValue? {
        get {
            guard (keychainDataKey.isLinkedToUserId && GPSKStorageService.shared.userId != nil) || !keychainDataKey.isLinkedToUserId
            else { fatalError("[GPSKMemoryCacheValues] No userId set") }
            let userId = GPSKStorageService.shared.userId  ?? "generic"
            let data = keychainDataKey.decoder(try? read(for: userId, service: keychainDataKey.service))
            return data ?? keychainDataKey.defaultValue
        }
        set {
            guard (keychainDataKey.isLinkedToUserId && GPSKStorageService.shared.userId != nil) || !keychainDataKey.isLinkedToUserId
            else { fatalError("[GPSKMemoryCacheValues] No userId set") }
            let userId = GPSKStorageService.shared.userId  ?? "generic"
            let data = keychainDataKey.encoder(newValue)
            if let data {
                try? store(data, for: userId, service: keychainDataKey.service)
            } else {
                try? delete(for: userId, service: keychainDataKey.service)
            }
        }
    }
}

// MARK: - Private

private extension GPSKKeychainDataValues {
    func read(for account: String, service: String) throws -> Data? {
        let attributes = [kSecAttrService: "\(domain).\(service)",
                          kSecAttrAccount: account,
                                kSecClass: kSecClassGenericPassword,
                           kSecReturnData: true
        ] as CFDictionary
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(attributes, &item)
        guard status == errSecSuccess else {
            throw GPSKSecureEnclaveError.unableToRead(message: status.message)
        }
        
        return item as? Data
    }
    
    func store(_ data: Data, for account: String, service: String, requiresBiometry: Bool = false) throws{
        let attributes = [kSecAttrService: "\(domain).\(service)",
                          kSecAttrAccount: account,
                                kSecClass: kSecClassGenericPassword,
                            kSecValueData: data,
        ] as CFDictionary
        
        let status = SecItemAdd(attributes, nil)
        guard status == errSecSuccess else {
            throw GPSKSecureEnclaveError.unableToWrite(message: status.message)
        }
    }
    
    func delete(for account: String, service: String) throws {
        let attributes = [kSecAttrService: "\(domain).\(service)",
                          kSecAttrAccount: account,
                                kSecClass: kSecClassGenericPassword,
        ] as CFDictionary
        
        let status = SecItemDelete(attributes)
        guard status == errSecSuccess else {
            throw GPSKSecureEnclaveError.unableToDelete(message: status.message)
        }
    }
}
