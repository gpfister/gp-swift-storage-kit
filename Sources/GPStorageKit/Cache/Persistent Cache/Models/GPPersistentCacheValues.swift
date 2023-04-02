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

public class GPPersistentCacheValues {
    public static let `default` = GPPersistentCacheValues()

    private let persistentCache: GPPersistentCacheController

    init(persistentCache: GPPersistentCacheController = .shared) {
        self.persistentCache = persistentCache
    }

    public subscript<GPKey: GPPersistentCacheKey>(
        _ persistentCacheKey: GPKey.Type
    ) -> GPKey.GPValue {
        get {
            let value: GPKey.GPValue? = value(forKey: persistentCacheKey.key)
            return value ?? persistentCacheKey.defaultValue
        }
        set {
            if let newValue = newValue as? GPOptionalValue, newValue.gpIsNil {
                removeValue(forKey: persistentCacheKey.key)
            } else {
                set(newValue, forKey: persistentCacheKey.key, entryLifetime: persistentCacheKey.entryLifetime)
            }
        }
    }
}

// MARK: - Private

private extension GPPersistentCacheValues {
    func value<GPValue: Codable>(forKey key: String) -> GPValue? {
        let codedValue: String? = persistentCache.value(forKey: key)

        guard let codedValue, let data = codedValue.data(using: .utf8) else { return nil }

        let value = try? JSONDecoder().decode(GPValue.self, from: data)
        return value
    }

    func set(_ value: (some Codable)?, forKey key: String, entryLifetime: TimeInterval) {
        if let data = try? JSONEncoder().encode(value), let value = String(data: data, encoding: .utf8) {
//            #if DEBUG
//                print("DEBUG: [ios-oskey-dev] (OSKPersistentCacheService) Converted to string '\(value)'")
//            #endif
            persistentCache.set(value, forKey: key, entryLifetime: entryLifetime)
        } else {
            removeValue(forKey: key)
        }
    }

    func removeValue(forKey key: String) {
        persistentCache.removeValue(forKey: key)
    }

//    func value<GPValue: Codable>(forKey key: String) -> GPValue? {
//        let value: GPValue? = persistentCache.value(forKey: key)
//        return value
//    }
//
//    func set<GPValue: Codable>(_ value: GPValue?, forKey key: String, defaultValue: GPValue? = nil, entryLifetime: TimeInterval) {
//        if let value = value {
//            persistentCache.set(value, forKey: key, entryLifetime: entryLifetime)
//        } else {
//            removeObject(forKey: key)
//        }
//    }
//
//    func removeObject(forKey key: String) {
//        persistentCache.removeObject(forKey: key)
//    }
}
