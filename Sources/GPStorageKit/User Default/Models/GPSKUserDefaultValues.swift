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
import Foundation

public class GPSKUserDefaultValues {
    public static let `default` = GPSKUserDefaultValues()

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    public subscript<GPSKKey: GPSKUserDefaultKey>(
        _ userDefaultKey: GPSKKey.Type
    ) -> GPSKKey.GPSKValue {
        get {
            guard (userDefaultKey.isLinkedToUserId && GPSKStorageService.shared.userId != nil) || !userDefaultKey.isLinkedToUserId
            else { fatalError("[GPSKUserDefaultValues] No userId set") }
            let key = userDefaultKey.isLinkedToUserId ? "user.\(GPSKStorageService.shared.userId ?? "").\(userDefaultKey.key)" : userDefaultKey.key
            let value: GPSKKey.GPSKValue? = value(forKey: key)
            return value ?? userDefaultKey.defaultValue
        }
        set {
            guard (userDefaultKey.isLinkedToUserId && GPSKStorageService.shared.userId != nil) || !userDefaultKey.isLinkedToUserId
            else { fatalError("[GPSKUserDefaultValues] No userId set") }
            let key = userDefaultKey.isLinkedToUserId ? "user.\(GPSKStorageService.shared.userId ?? "").\(userDefaultKey.key)" : userDefaultKey.key
            if let newValue = newValue as? GPSKOptionalValue, newValue.gskIsNil {
                removeObject(forKey: key)
            } else {
                set(newValue, forKey: key)
            }
        }
    }

    public subscript<GPSKKey: GPSKUserDefaultCodableKey>(
        _ userDefaultKey: GPSKKey.Type
    ) -> GPSKKey.GPSKValue {
        get {
            guard (userDefaultKey.isLinkedToUserId && GPSKStorageService.shared.userId != nil) || !userDefaultKey.isLinkedToUserId
            else { /* return userDefaultKey.defaultValue */ fatalError("[GPSKUserDefaultValues] No userId set") }
            let key = userDefaultKey.isLinkedToUserId ? "user.\(GPSKStorageService.shared.userId ?? "").\(userDefaultKey.key)" : userDefaultKey.key
            let data: Data? = value(forKey: key)
            guard let data, let value = try? JSONDecoder().decode(GPSKKey.GPSKValue.self, from: data) else {
                return userDefaultKey.defaultValue
            }
            return value
        }
        set {
            guard (userDefaultKey.isLinkedToUserId && GPSKStorageService.shared.userId != nil) || !userDefaultKey.isLinkedToUserId
            else { /* return */ fatalError("[GPSKUserDefaultValues] No userId set") }
            let key = userDefaultKey.isLinkedToUserId ? "user.\(GPSKStorageService.shared.userId ?? "").\(userDefaultKey.key)" : userDefaultKey.key
            if let newValue = newValue as? GPSKOptionalValue, newValue.gskIsNil {
                removeObject(forKey: key)
            } else {
                guard let data = try? JSONEncoder().encode(newValue) else {
                    removeObject(forKey: key)
                    return
                }
                set(data, forKey: key)
            }
        }
    }

    func resetAllData() {
        userDefaults.dictionaryRepresentation().keys.forEach { self.userDefaults.removeObject(forKey: $0) }
    }

    func resetUserData() {
        guard let userId = GPSKStorageService.shared.userId else { return }
        for key in userDefaults.dictionaryRepresentation().keys {
            if key.starts(with: "user.\(userId).") { userDefaults.removeObject(forKey: key) }
        }
    }
}

// MARK: - Private

private extension GPSKUserDefaultValues {
    func value<GPSKValue>(forKey key: String) -> GPSKValue? {
        userDefaults.object(forKey: key) as? GPSKValue
    }

    func set(_ value: some Any, forKey key: String) {
        userDefaults.set(value, forKey: key)
    }

    func removeObject(forKey key: String) {
        userDefaults.removeObject(forKey: key)
    }
}
