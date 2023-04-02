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

final class GPPersistentCacheController {
    typealias GPCodableCache = GPCacheController<String, String>
    static let shared = GPPersistentCacheController()

    let name: String
    private let cacheService: GPCodableCache

    init(name: String = "data", maximumEntryCount: Int = 1024) {
        self.name = name
        let cacheName = "\(name).cache"
        do {
            let fileManager: FileManager = .default
            let folderURL = try fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let dataCacheFolderURL = folderURL.appendingPathComponent(name.capitalized)
            let fileURL = dataCacheFolderURL.appendingPathComponent(cacheName)
            if fileManager.fileExists(atPath: fileURL.path) {
                //                #if DEBUG
                //                    let content = try fileManager.contentsOfDirectory(atPath: dataCacheFolderURL.path)
                //                    print("DEBUG: [ios-oskey-dev] (GPPersistentCache) Found a persistent cache \(cacheName)")
                //
                //                    print("DEBUG: [ios-oskey-dev] (GPPersistentCache) Persistent cache content: ")
                //                    for element in content {
                //                        print("DEBUG: [ios-oskey-dev] (GPPersistentCache)  - \(element)")
                //                    }
                //                #endif
                let data = try Data(contentsOf: fileURL)
                cacheService = try JSONDecoder().decode(GPCodableCache.self, from: data)
                //                #if DEBUG
                //                    print("DEBUG: [ios-oskey-dev] (GPPersistentCache) Loading persistent cache \(cacheName)")
                //                #endif
                cacheService.name = name
                cacheService.maximumEntryCount = maximumEntryCount
                return
            }
        } catch {
            //            #if DEBUG
            //                print("DEBUG: [ios-oskey-dev] (GPPersistentCache) Unable to read persistent cache \(cacheName) (\(error.localizedDescription))")
            //                print("DEBUG: [ios-oskey-dev] (GPPersistentCache) Allocating new persistent cache \(cacheName)")
            //            #endif
        }
        cacheService = .init(name: name, maximumEntryCount: maximumEntryCount)
        try? cacheService.saveCacheOnDisk()
        //        do {
        //            try cacheService.saveCacheOnDisk()
        //        } catch {
        //            #if DEBUG
        //                print("DEBUG: [ios-oskey-dev] (GPPersistentCache) Unable to save persistent cache \(cacheName) (\(error.localizedDescription))")
        //            #endif
        //        }

        try? cacheService.saveCacheOnDisk()
    }

    func value<GPValue: Codable>(forKey key: String) -> GPValue? {
        let value = cacheService.readValue(forKey: key)

        guard let value else { return nil }

        guard let value = value.data(using: .utf8) else { return nil }

        if let value = try? JSONDecoder().decode(GPValue.self, from: value) {
            return value
        } else {
            return nil
        }
    }

    func set(_ value: some Codable, forKey key: String, entryLifetime: TimeInterval) {
        if let value = try? JSONEncoder().encode(value), let value = String(data: value, encoding: .utf8) {
            //            #if DEBUG
            //                print("DEBUG: [ios-oskey-dev] (GPPersistentCache) Converted to string '\(value)'")
            //            #endif
            cacheService.storeValue(value, forKey: key, entryLifetime: entryLifetime)
            try? cacheService.saveCacheOnDisk()
        }
    }

    func removeValue(forKey key: String) {
        cacheService.removeValue(forKey: key)
        try? cacheService.saveCacheOnDisk()
    }
}
