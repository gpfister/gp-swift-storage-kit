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

/// References: https://www.avanderlee.com/swift/appstorage-explained/

class GPUserDefaultsService {
    static let shared: GPUserDefaultsService = .init()

    let valueChangedSubject = PassthroughSubject<PartialKeyPath<GPUserDefaultValues>, Never>()

    private let userDefaultValues: GPUserDefaultValues

    init(userDefaultValues: GPUserDefaultValues = .default) {
        self.userDefaultValues = userDefaultValues
    }

    subscript<GPValue>(_ keyPath: ReferenceWritableKeyPath<GPUserDefaultValues, GPValue>) -> GPValue {
        get { userDefaultValues[keyPath: keyPath] }
        set {
            userDefaultValues[keyPath: keyPath] = newValue
            valueChangedSubject.send(keyPath)
        }
    }
}
