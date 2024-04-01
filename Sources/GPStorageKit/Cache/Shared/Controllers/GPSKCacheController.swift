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

/// Reference https://www.swiftbysundell.com/articles/caching-in-swift/

public final class GPSKCacheController<GPSKKey: Hashable, GPSKValue>: NSObject, NSCacheDelegate {
    var name: String

    private let wrapped = NSCache<GPWrappedKey, GPEntry>()
    private let keyTracker = GPSKKeyTracker()
    private let fileManager: FileManager = .default

    init(name: String = "standard",
         maximumEntryCount: Int = 1024)
    {
        self.name = name
        wrapped.countLimit = maximumEntryCount
        super.init()

        wrapped.delegate = self
    }

    deinit {}

    var maximumEntryCount: Int {
        get { wrapped.countLimit }
        set { wrapped.countLimit = newValue }
    }

    func readValue(forKey key: GPSKKey) -> GPSKValue? {
        guard let entry = wrapped.object(forKey: GPWrappedKey(key)) else {
            return nil
        }

        guard Date() < entry.expirationDate else {
            removeValue(forKey: key)
            return nil
        }

        return entry.value
    }

    func storeValue(_ value: GPSKValue, forKey key: GPSKKey, entryLifetime: TimeInterval) {
        let expirationDate = Date(timeIntervalSinceNow: entryLifetime)
        let entry = GPEntry(key: key, value: value, expirationDate: expirationDate)
        wrapped.setObject(entry, forKey: GPWrappedKey(key))
        keyTracker.keys.insert(key)
    }

    func removeValue(forKey key: GPSKKey) {
        wrapped.removeObject(forKey: GPWrappedKey(key))
    }

    public func cache(_: NSCache<AnyObject, AnyObject>,
                      willEvictObject object: Any)
    {
        guard let entry = object as? GPEntry else {
            return
        }

        keyTracker.keys.remove(entry.key)
    }
}

private extension GPSKCacheController {
    final class GPWrappedKey: NSObject {
        let key: GPSKKey

        init(_ key: GPSKKey) { self.key = key }

        override var hash: Int { key.hashValue }

        override func isEqual(_ object: Any?) -> Bool {
            guard let value = object as? GPWrappedKey else {
                return false
            }

            return value.key == key
        }
    }
}

private extension GPSKCacheController {
    final class GPEntry {
        let key: GPSKKey
        let value: GPSKValue
        let expirationDate: Date

        init(key: GPSKKey, value: GPSKValue, expirationDate: Date) {
            self.key = key
            self.value = value
            self.expirationDate = expirationDate
        }
    }
}

private extension GPSKCacheController {
    final class GPSKKeyTracker: NSObject, NSCacheDelegate {
        var keys = Set<GPSKKey>()
    }
}

private extension GPSKCacheController {
    func entry(forKey key: GPSKKey) -> GPEntry? {
        guard let entry = wrapped.object(forKey: GPWrappedKey(key)) else {
            return nil
        }

        guard Date() < entry.expirationDate else {
            removeValue(forKey: key)
            return nil
        }

        return entry
    }

    func insert(_ entry: GPEntry) {
        wrapped.setObject(entry, forKey: GPWrappedKey(entry.key))
        keyTracker.keys.insert(entry.key)
    }
}

extension GPSKCacheController.GPEntry: Codable where GPSKKey: Codable, GPSKValue: Codable {}

extension GPSKCacheController: Codable where GPSKKey: Codable, GPSKValue: Codable {
    public convenience init(from decoder: Decoder) throws {
        self.init()

        let container = try decoder.singleValueContainer()
        let entries = try container.decode([GPEntry].self)
        for entry in entries {
            if entry.expirationDate >= Date() {
                insert(entry)
            }
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(keyTracker.keys.compactMap { entry(forKey: $0) })
    }
}

extension GPSKCacheController where GPSKKey: Codable, GPSKValue: Codable {
    func saveCacheOnDisk() throws {
        let rootFolderURL = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let cacheFolderURL = rootFolderURL.appendingPathComponent(name.capitalized)

        // Create folder is not yet there
        if !fileManager.fileExists(atPath: cacheFolderURL.path) {
            try fileManager.createDirectory(
                at: cacheFolderURL,
                withIntermediateDirectories: false,
                attributes: nil
            )
        }

        // Save file
        let fileURL = cacheFolderURL.appendingPathComponent(name + ".cache")
        let data = try JSONEncoder().encode(self)
        try data.write(to: fileURL)
    }
}
