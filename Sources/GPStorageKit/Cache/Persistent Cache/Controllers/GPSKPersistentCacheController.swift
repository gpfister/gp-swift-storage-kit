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

final class GPSKPersistentCacheController {
    typealias GPCodableCacheController = GPSKCacheController<String, String>
    static let shared = GPSKPersistentCacheController()

    let name: String
    private let cacheController: GPCodableCacheController

    init(name: String = "data", maximumEntryCount: Int = 1024) {
        self.name = name
        let cacheName = "\(name).cache"
        do {
            let fileManager: FileManager = .default
            let folderURL = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let dataCacheFolderURL = folderURL.appendingPathComponent(name.capitalized)
            let fileURL = dataCacheFolderURL.appendingPathComponent(cacheName)
            if fileManager.fileExists(atPath: fileURL.path) {
                let data = try Data(contentsOf: fileURL)
                cacheController = try JSONDecoder().decode(GPCodableCacheController.self, from: data)
                cacheController.name = name
                cacheController.maximumEntryCount = maximumEntryCount
                return
            }
        } catch {}
        cacheController = .init(name: name, maximumEntryCount: maximumEntryCount)
        try? cacheController.saveCacheOnDisk()
    }

    func value<GPSKValue: Codable>(forKey key: String) -> GPSKValue? {
        let value = cacheController.readValue(forKey: key)

        guard let value else { return nil }

        guard let value = value.data(using: .utf8) else { return nil }

        if let value = try? JSONDecoder().decode(GPSKValue.self, from: value) {
            return value
        } else {
            return nil
        }
    }

    func set(_ value: some Codable, forKey key: String, entryLifetime: TimeInterval) {
        if let value = try? JSONEncoder().encode(value), let value = String(data: value, encoding: .utf8) {
            cacheController.storeValue(value, forKey: key, entryLifetime: entryLifetime)
            try? cacheController.saveCacheOnDisk()
        }
    }

    func removeValue(forKey key: String) {
        cacheController.removeValue(forKey: key)
        try? cacheController.saveCacheOnDisk()
    }
}
