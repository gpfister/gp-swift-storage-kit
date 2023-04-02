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
import CryptoKit
import Foundation

/// References: https://www.avanderlee.com/swift/appstorage-explained/

// TODO: OSKSecKeyConvertible should include query parameters (to read)
// TODO: OSKSecKeyConvertible should include convertion to SecKey (to write)

public final class GPKeychainSecKeyService {
    public static let shared = GPKeychainSecKeyService()

    let valueChangedSubject = PassthroughSubject<PartialKeyPath<GPKeychainSecKeyValues>, Never>()

    private let keychainSecKeyValues: GPKeychainSecKeyValues

    init(keychainSecKeyValues: GPKeychainSecKeyValues = .default) {
        self.keychainSecKeyValues = keychainSecKeyValues
    }

    subscript<GPValue>(_ keyPath: ReferenceWritableKeyPath<GPKeychainSecKeyValues, GPValue>) -> GPValue {
        get { keychainSecKeyValues[keyPath: keyPath] }
        set {
            keychainSecKeyValues[keyPath: keyPath] = newValue
            valueChangedSubject.send(keyPath)
        }
    }
}
