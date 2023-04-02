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
import SwiftUI

/// References:
///   - https://www.avanderlee.com/swift/appstorage-explained/
///   - https://www.hackingwithswift.com/quick-start/swiftui/observable-objects-environment-objects-and-published

/// Wraps a user default to be published inside an ``ObserableObject``.
///
@propertyWrapper public class GPPublishedPersistentCacheEntry<GPValue> {
    private let keyPath: ReferenceWritableKeyPath<GPPersistentCacheValues, GPValue>
    private let persistentCacheService = GPPersistentCacheService.shared
    let subject: CurrentValueSubject<GPValue, Never>
    let publisher: AnyPublisher<GPValue, Never>
    private var cancellables = Set<AnyCancellable>()

    public init(_ keyPath: ReferenceWritableKeyPath<GPPersistentCacheValues, GPValue>) {
        self.keyPath = keyPath
        subject = .init(persistentCacheService[keyPath])
        publisher = subject.eraseToAnyPublisher()
        persistentCacheService.valueChangedSubject
            .filter { akeyPath in
                akeyPath == keyPath
            }
            .eraseToAnyPublisher()
            .sink { _ in
                self.subject.send(self.persistentCacheService[keyPath])
            }
            .store(in: &cancellables)
    }

    deinit {
        cancellables.forEach { cancellable in
            cancellable.cancel()
        }
    }

    public func update() {
        subject.send(persistentCacheService[keyPath])
    }

    @available(*, unavailable, message: "Wrapped value should not be used.")
    public var wrappedValue: GPValue {
        get { fatalError() }
        set { fatalError() }
    }

    public static subscript<GPEnclosingType: ObservableObject>(
        _enclosingInstance instance: GPEnclosingType,
        wrapped _: ReferenceWritableKeyPath<GPEnclosingType, GPValue>,
        storage storageKeyPath: ReferenceWritableKeyPath<GPEnclosingType, GPPublishedPersistentCacheEntry>
    ) -> GPValue {
        get {
            instance[keyPath: storageKeyPath].subject.value
        }
        set {
            DispatchQueue.main.async {
                (instance.objectWillChange as! ObservableObjectPublisher).send()
            }
            instance[keyPath: storageKeyPath].subject.send(newValue)
            instance[keyPath: storageKeyPath].persistentCacheService[instance[keyPath: storageKeyPath].keyPath] = newValue
        }
    }

    public var projectedValue: AnyPublisher<GPValue, Never> { publisher }
}
