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

public final class GPMemoryCacheController {
    public static let shared = GPMemoryCacheController()

    let cache: GPCacheController<String, Any>

    init(name: String = "data", maximumEntryCount: Int = 1024) {
        cache = .init(name: name, maximumEntryCount: maximumEntryCount)
    }

    func value(forKey key: String) -> Any? {
        cache.readValue(forKey: key)
    }

    func set(_ value: Any, forKey key: String, entryLifetime: TimeInterval) {
        cache.storeValue(value, forKey: key, entryLifetime: entryLifetime)
    }

    func removeValue(forKey key: String) {
        cache.removeValue(forKey: key)
    }
}
