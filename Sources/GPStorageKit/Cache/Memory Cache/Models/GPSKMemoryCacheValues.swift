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

public class GPSKMemoryCacheValues {
    public static let `default` = GPSKMemoryCacheValues()

    private let memoryCache: GPSKMemoryCacheController

    init(memoryCache: GPSKMemoryCacheController = .shared) {
        self.memoryCache = memoryCache
    }

    public subscript<GPSKKey: GPSKMemoryCacheKey>(
        _ memoryCacheKey: GPSKKey.Type
    ) -> GPSKKey.GPSKValue {
        get {
            guard (memoryCacheKey.isLinkedToUserId && GPSKStorageService.shared.userId != nil) || !memoryCacheKey.isLinkedToUserId
            else { fatalError("[GPSKMemoryCacheValues] No userId set") }
            let key = memoryCacheKey.isLinkedToUserId ? "user.\(GPSKStorageService.shared.userId ?? "").\(memoryCacheKey.key)" : memoryCacheKey.key
            let value: GPSKKey.GPSKValue? = value(forKey: key)
            return value ?? memoryCacheKey.defaultValue
        }
        set {
            guard (memoryCacheKey.isLinkedToUserId && GPSKStorageService.shared.userId != nil) || !memoryCacheKey.isLinkedToUserId
            else { fatalError("[GPSKMemoryCacheValues] No userId set") }
            let key = memoryCacheKey.isLinkedToUserId ? "user.\(GPSKStorageService.shared.userId ?? "").\(memoryCacheKey.key)" : memoryCacheKey.key
            if let newValue = newValue as? GPSKOptionalValue, newValue.gskIsNil {
                removeValue(forKey: key)
            } else {
                set(newValue, forKey: key, entryLifetime: memoryCacheKey.entryLifetime)
            }
        }
    }
}

// MARK: - Private

private extension GPSKMemoryCacheValues {
    func value<GPSKValue>(forKey key: String) -> GPSKValue? {
        memoryCache.value(forKey: key) as? GPSKValue
    }

    func set(_ value: (some Any)?, forKey key: String, entryLifetime: TimeInterval) {
        if let value {
            memoryCache.set(value, forKey: key, entryLifetime: entryLifetime)
        } else {
            removeValue(forKey: key)
        }
    }

    func removeValue(forKey key: String) {
        memoryCache.removeValue(forKey: key)
    }
}
