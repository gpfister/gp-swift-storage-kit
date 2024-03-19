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

public class GPSCPersistentCacheValues {
    public static let `default` = GPSCPersistentCacheValues()

    private let persistentCache: GPSCPersistentCacheController

    init(persistentCache: GPSCPersistentCacheController = .shared) {
        self.persistentCache = persistentCache
    }

    public subscript<GPSCKey: GPSCPersistentCacheKey>(
        _ persistentCacheKey: GPSCKey.Type
    ) -> GPSCKey.GPSCValue {
        get {
            guard (persistentCacheKey.isLinkedToUserId && GPSCStorageService.shared.userId != nil) || !persistentCacheKey.isLinkedToUserId
            else { /* return userDefaultKey.defaultValue */ fatalError("[GPSCUserDefaultValues] No userId set") }
            let key = persistentCacheKey.isLinkedToUserId ? "user.\(GPSCStorageService.shared.userId ?? "").\(persistentCacheKey.key)" : persistentCacheKey.key
            let value: GPSCKey.GPSCValue? = value(forKey: key)
            return value ?? persistentCacheKey.defaultValue
        }
        set {
            guard (persistentCacheKey.isLinkedToUserId && GPSCStorageService.shared.userId != nil) || !persistentCacheKey.isLinkedToUserId
            else { /* return userDefaultKey.defaultValue */ fatalError("[GPSCUserDefaultValues] No userId set") }
            let key = persistentCacheKey.isLinkedToUserId ? "user.\(GPSCStorageService.shared.userId ?? "").\(persistentCacheKey.key)" : persistentCacheKey.key
            if let newValue = newValue as? GPSCOptionalValue, newValue.gpIsNil {
                removeValue(forKey: key)
            } else {
                set(newValue, forKey: key, entryLifetime: persistentCacheKey.entryLifetime)
            }
        }
    }
}

// MARK: - Private

private extension GPSCPersistentCacheValues {
    func value<GPSCValue: Codable>(forKey key: String) -> GPSCValue? {
        let codedValue: String? = persistentCache.value(forKey: key)

        guard let codedValue, let data = codedValue.data(using: .utf8) else { return nil }

        let value = try? JSONDecoder().decode(GPSCValue.self, from: data)
        return value
    }

    func set(_ value: (some Codable)?, forKey key: String, entryLifetime: TimeInterval) {
        if let data = try? JSONEncoder().encode(value), let value = String(data: data, encoding: .utf8) {
            persistentCache.set(value, forKey: key, entryLifetime: entryLifetime)
        } else {
            removeValue(forKey: key)
        }
    }

    func removeValue(forKey key: String) {
        persistentCache.removeValue(forKey: key)
    }
}
