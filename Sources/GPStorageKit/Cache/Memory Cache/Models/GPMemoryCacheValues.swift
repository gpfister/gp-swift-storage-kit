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

public class GPMemoryCacheValues {
    public static let `default` = GPMemoryCacheValues()

    private let memoryCache: GPMemoryCacheController

    init(memoryCache: GPMemoryCacheController = .shared) {
        self.memoryCache = memoryCache
    }

    public subscript<GPKey: GPMemoryCacheKey>(
        _ memoryCacheKey: GPKey.Type
    ) -> GPKey.GPValue {
        get {
            let value: GPKey.GPValue? = value(forKey: memoryCacheKey.key)
            return value ?? memoryCacheKey.defaultValue
        }
        set {
            if let newValue = newValue as? GPOptionalValue, newValue.gpIsNil {
                removeValue(forKey: memoryCacheKey.key)
            } else {
                set(newValue, forKey: memoryCacheKey.key, entryLifetime: memoryCacheKey.entryLifetime)
            }
        }
    }
}

// MARK: - Private

private extension GPMemoryCacheValues {
    func value<GPValue>(forKey key: String) -> GPValue? {
        memoryCache.value(forKey: key) as? GPValue
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
