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
import Foundation

/// Reference https://www.swiftbysundell.com/articles/caching-in-swift/

public final class GPCacheController<GPKey: Hashable, GPValue>: NSObject, NSCacheDelegate {
    var name: String

    private let wrapped = NSCache<GPWrappedKey, GPEntry>()
    private let keyTracker = GPKeyTracker()
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

    func readValue(forKey key: GPKey) -> GPValue? {
        guard let entry = wrapped.object(forKey: GPWrappedKey(key)) else {
            return nil
        }

        guard Date() < entry.expirationDate else {
            removeValue(forKey: key)
            return nil
        }

        //        #if DEBUG
        //            print("DEBUG: [ios-oskey-dev] \(self) Reading key \(entry.key) = \(entry.value) (expires at \(entry.expirationDate.ISO8601Format()) or \(entry.expirationDate.timeIntervalSinceNow) seconds) from cache '\(name)'")
        //        #endif

        return entry.value
    }

    func storeValue(_ value: GPValue, forKey key: GPKey, entryLifetime: TimeInterval) {
        let expirationDate = Date(timeIntervalSinceNow: entryLifetime)
        let entry = GPEntry(key: key, value: value, expirationDate: expirationDate)
        //        #if DEBUG
        //            print("DEBUG: [ios-oskey-dev] \(self) Writing key \(key) = \(value) (expires at \(expirationDate.ISO8601Format()) or in \(expirationDate.timeIntervalSinceNow) seconds) from cache '\(name)'")
        //        #endif
        wrapped.setObject(entry, forKey: GPWrappedKey(key))
        keyTracker.keys.insert(key)
    }

    func removeValue(forKey key: GPKey) {
        wrapped.removeObject(forKey: GPWrappedKey(key))

        //        #if DEBUG
        //            print("DEBUG: [ios-oskey-dev] \(self) Removing key \(key) from cache '\(name)'")
        //        #endif
    }

    public func cache(_: NSCache<AnyObject, AnyObject>,
                      willEvictObject object: Any)
    {
        guard let entry = object as? GPEntry else {
            return
        }

        // #if DEBUG
        //        print("DEBUG: [ios-oskey-dev] \(self) Entry: \(entry.key) = \(entry.value) was evicted")
        // #endif

        keyTracker.keys.remove(entry.key)
    }
}

private extension GPCacheController {
    final class GPWrappedKey: NSObject {
        let key: GPKey

        init(_ key: GPKey) { self.key = key }

        override var hash: Int { key.hashValue }

        override func isEqual(_ object: Any?) -> Bool {
            guard let value = object as? GPWrappedKey else {
                return false
            }

            return value.key == key
        }
    }
}

private extension GPCacheController {
    final class GPEntry {
        let key: GPKey
        let value: GPValue
        let expirationDate: Date

        init(key: GPKey, value: GPValue, expirationDate: Date) {
            self.key = key
            self.value = value
            self.expirationDate = expirationDate
        }
    }
}

private extension GPCacheController {
    final class GPKeyTracker: NSObject, NSCacheDelegate {
        var keys = Set<GPKey>()
    }
}

private extension GPCacheController {
    func entry(forKey key: GPKey) -> GPEntry? {
        guard let entry = wrapped.object(forKey: GPWrappedKey(key)) else {
            return nil
        }

        guard Date() < entry.expirationDate else {
            // #if DEBUG
            //            print("DEBUG: [ios-oskey-dev] \(self) Entry: \(entry.key) = \(entry.value) has expired since \(entry.expirationDate.ISO8601Format())")
            // #endif
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

extension GPCacheController.GPEntry: Codable where GPKey: Codable, GPValue: Codable {}

extension GPCacheController: Codable where GPKey: Codable, GPValue: Codable {
    public convenience init(from decoder: Decoder) throws {
        self.init()

        let container = try decoder.singleValueContainer()
        let entries = try container.decode([GPEntry].self)
        entries.forEach {
            // #if DEBUG
            //            print("DEBUG: [ios-oskey-dev] \(self) Found entry: \($0.key) = \($0.value) (expires on \($0.expirationDate.ISO8601Format()))")
            // #endif
            if $0.expirationDate >= Date() {
                insert($0)
            }
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(keyTracker.keys.compactMap { entry(forKey: $0) })
    }
}

extension GPCacheController where GPKey: Codable, GPValue: Codable {
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
