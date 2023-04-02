//
// gp-swift-storage-kit
// Copyright (c) 2022-2023, Greg PFISTER. MIT License.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Combine
import CryptoKit
import Foundation

public class GPKeychainSecKeyValues {
    public static let `default` = GPKeychainSecKeyValues()

    var values: [String: Any] = [:]

    private let domain: String

    init(domain: String? = nil) {
        self.domain = domain ?? Bundle.main.bundleIdentifier!
    }

    public subscript<GPKey: GPKeychainSecKeyKey>(
        _ keychainSecKeyKey: GPKey.Type
    ) -> GPKey.GPValue? {
        get {
            let secKey: GPKey.GPValue? = try? readSecKey(forKey: keychainSecKeyKey.key)
            return secKey ?? keychainSecKeyKey.defaultValue
        }
        set {
            try? storeSecKey(newValue, forKey: keychainSecKeyKey.key)
        }
    }
}

// MARK: - Private

private extension GPKeychainSecKeyValues {
    func readSecKey<T: GPSecKeyConvertible>(forKey key: String) throws -> T? {
        // Get the SecKey object
        let secKey = try internalReadSecKey(forKey: key)

        // Stop here if no key was found
        guard let secKey else {
            return nil
        }

        // Convert the SecKey into a CryptoKit key.
        var error: Unmanaged<CFError>?
        guard let data = SecKeyCopyExternalRepresentation(secKey, &error) as Data? else {
            throw GPKeychainError.unableToParseSecKeyRepresentation(error.debugDescription)
        }
        do {
            let key = try T(x963Representation: data)
            return key
        } catch {
            throw GPKeychainError.unableToParseSecKeyRepresentation(error.localizedDescription)
        }
    }

    func internalReadSecKey(forKey key: String) throws -> SecKey? {
        // Seek an elliptic-curve key with a given label.
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
        case let status: throw GPKeychainError.unableToRead(status.message)
        }

        return secKey
    }

    func storeSecKey(_ secKey: (some GPSecKeyConvertible)?, forKey key: String) throws {
        if let secKey {
            if (try? internalReadSecKey(forKey: key)) != nil {
                try internalDeleteSecKey(forKey: key)
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
                throw GPKeychainError.unableToCreateSecKeyRepresentation(error.debugDescription)
            }

            try internalStoreSecKey(secKey, forKey: key)
        } else {
            try internalDeleteSecKey(forKey: key)
        }
    }

    func internalStoreSecKey(_ secKey: SecKey, forKey key: String) throws {
        // Describe the add operation.
        let query = [kSecClass: kSecClassKey,
                     kSecAttrApplicationLabel: "\(domain).\(key)",
                     kSecAttrAccessible: kSecAttrAccessibleWhenUnlocked,
                     kSecUseDataProtectionKeychain: true,
                     kSecValueRef: secKey] as [String: Any]

        // Add the key to the keychain.
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw GPKeychainError.unableToWrite(status.message)
        }
    }

    func internalDeleteSecKey(forKey key: String) throws {
        // Describe the add operation.
        let query = [kSecClass: kSecClassKey,
                     kSecAttrApplicationLabel: "\(domain).\(key)",
                     kSecAttrAccessible: kSecAttrAccessibleWhenUnlocked,
                     kSecUseDataProtectionKeychain: true] as [String: Any]

        // Add the key to the keychain.
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess else {
            throw GPKeychainError.unableToDelete(status.message)
        }
    }
}
