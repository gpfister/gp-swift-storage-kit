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

public class GPSKSecureEnclavePrivateKeyValues {
    public static let `default` = GPSKSecureEnclavePrivateKeyValues()

    var values: [String: Any] = [:]

    private let domain: String

    init(domain: String? = nil) {
        self.domain = domain ?? Bundle.main.bundleIdentifier!
    }

    public subscript<GPSKKey: GPSKSecureEnclavePrivateKeyKey>(
        _ privateKey: GPSKKey.Type
    ) -> GPSKKey.GPSKValue? {
        get {
            guard let userId = GPSKStorageService.shared.userId else { fatalError("[GPSKSecureEnclavePrivateKeyValues] No userId set") }
            return try? read(for: userId, service: privateKey.service)
        }
        set {
            guard let userId = GPSKStorageService.shared.userId else { fatalError("[GPSKSecureEnclavePrivateKeyValues] No userId set") }
            try? store(newValue, for: userId, service: privateKey.service)
        }
    }
}

// MARK: - Private

private extension GPSKSecureEnclavePrivateKeyValues {
    func read<T: GPSKSecureEnclavePrivateKeyConvertible>(for account: String, service: String) throws -> T? {
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
        
        do {
            return try T(dataRepresentation: (item as! Data))
        } catch {
            throw GPSKSecureEnclaveError.unableToParseKeyRepresentation(error: error)
        }
    }
    
    func store(_ privateKey: (some GPSKSecureEnclavePrivateKeyConvertible)?, for account: String, service: String, requiresBiometry: Bool = false) throws{
        if let privateKey {
            let attributes = [kSecAttrService: "\(domain).\(service)",
                              kSecAttrAccount: account,
                                    kSecClass: kSecClassGenericPassword,
                                kSecValueData: privateKey.dataRepresentation,
            ] as CFDictionary
            
            let status = SecItemAdd(attributes, nil)
            guard status == errSecSuccess else {
                throw GPSKSecureEnclaveError.unableToWrite(message: status.message)
            }
        } else {
            try delete(for: account, service: service)
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
