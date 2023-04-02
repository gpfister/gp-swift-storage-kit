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

class GPMemoryCacheService {
    static let shared = GPMemoryCacheService()

    let valueChangedSubject = PassthroughSubject<PartialKeyPath<GPMemoryCacheValues>, Never>()

    private let memoryCacheValues: GPMemoryCacheValues

    init(memoryCacheValues: GPMemoryCacheValues = .default) {
        self.memoryCacheValues = memoryCacheValues
    }

    subscript<GPValue>(_ keyPath: ReferenceWritableKeyPath<GPMemoryCacheValues, GPValue>) -> GPValue {
        get { memoryCacheValues[keyPath: keyPath] }
        set {
            memoryCacheValues[keyPath: keyPath] = newValue
            valueChangedSubject.send(keyPath)
        }
    }
}
