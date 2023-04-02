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

@propertyWrapper public struct GPUserDefault<GPValue: Equatable>: DynamicProperty {
    @ObservedObject private var observer: GPObservableObject

    private let keyPath: ReferenceWritableKeyPath<GPUserDefaultValues, GPValue>
    private let userDefaultsService = GPUserDefaultsService.shared
    private let subject: CurrentValueSubject<GPValue, Never>

    public init(_ keyPath: ReferenceWritableKeyPath<GPUserDefaultValues, GPValue>) {
        self.keyPath = keyPath
        subject = .init(userDefaultsService[keyPath])
        let valueChanged = userDefaultsService.valueChangedSubject
            .filter { aKeyPath in
                aKeyPath == keyPath
            }
            .map { _ in () }
            .eraseToAnyPublisher()
        observer = .init(publisher: valueChanged)
    }

    public func update() {
        subject.send(userDefaultsService[keyPath])
    }

    public var wrappedValue: GPValue {
        get {
            subject.value
        }
        nonmutating set {
            userDefaultsService[keyPath] = newValue
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

private extension GPUserDefault {
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
