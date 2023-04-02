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

public class GPUserDefaultValues {
    public static let `default` = GPUserDefaultValues()

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    public subscript<GPKey: GPUserDefaultKey>(
        _ userDefaultKey: GPKey.Type
    ) -> GPKey.GPValue {
        get {
            let value: GPKey.GPValue? = value(forKey: userDefaultKey.key)
            return value ?? userDefaultKey.defaultValue
        }
        set {
            if let newValue = newValue as? GPOptionalValue, newValue.gpIsNil {
                removeObject(forKey: userDefaultKey.key)
            } else {
                set(newValue, forKey: userDefaultKey.key)
            }
        }
    }

    public subscript<GPKey: GPUserDefaultCodableKey>(
        _ userDefaultKey: GPKey.Type
    ) -> GPKey.GPValue {
        get {
            let data: Data? = value(forKey: userDefaultKey.key)
            guard let data, let value = try? JSONDecoder().decode(GPKey.GPValue.self, from: data) else {
                return userDefaultKey.defaultValue
            }
            return value
        }
        set {
            if let newValue = newValue as? GPOptionalValue, newValue.gpIsNil {
                removeObject(forKey: userDefaultKey.key)
            } else {
                guard let data = try? JSONEncoder().encode(newValue) else {
                    removeObject(forKey: userDefaultKey.key)
                    return
                }
                set(data, forKey: userDefaultKey.key)
            }
        }
    }
}

// MARK: - Private

private extension GPUserDefaultValues {
    func value<GPValue>(forKey key: String) -> GPValue? {
        userDefaults.object(forKey: key) as? GPValue
    }

    func set(_ value: some Any, forKey key: String) {
        userDefaults.set(value, forKey: key)
    }

    func removeObject(forKey key: String) {
        userDefaults.removeObject(forKey: key)
    }
}
