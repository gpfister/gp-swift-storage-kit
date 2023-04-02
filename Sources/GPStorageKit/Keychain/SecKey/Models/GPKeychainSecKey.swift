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

@propertyWrapper public struct GPKeychainSecKey<GPValue>: DynamicProperty {
    @ObservedObject private var keychainObserver: GPObservableObject

    private let keyPath: ReferenceWritableKeyPath<GPKeychainSecKeyValues, GPValue>
    private let keychainSecKeyService = GPKeychainSecKeyService.shared
    private let subject: CurrentValueSubject<GPValue, Never>

    public init(_ keyPath: ReferenceWritableKeyPath<GPKeychainSecKeyValues, GPValue>) {
        self.keyPath = keyPath
        subject = .init(keychainSecKeyService[keyPath])
        let publisher = keychainSecKeyService.valueChangedSubject
            .filter { aKeyPath in
                aKeyPath == keyPath
            }
            .map { _ in () }
            .eraseToAnyPublisher()
        keychainObserver = .init(publisher: publisher)
    }

    public func update() {
        subject.send(keychainSecKeyService[keyPath])
    }

    public var wrappedValue: GPValue {
        get {
            subject.value
        }
        nonmutating set {
            keychainSecKeyService[keyPath] = newValue
        }
    }

    public var projectedValue: Binding<GPValue> {
        Binding(
            get: { subject.value },
            set: { wrappedValue = $0 }
        )
    }
}

// MARK: - Private

private extension GPKeychainSecKey {
    final class GPObservableObject: ObservableObject {
        var subscriber: AnyCancellable?

        init(publisher: AnyPublisher<Void, Never>) {
            subscriber = publisher.sink { _ in
                self.objectWillChange.send()
            }
        }

        deinit {
            if let subscriber {
                subscriber.cancel()
            }
        }
    }
}
