//
// gp-swift-storage-kit
// Copyright (c) 2022-2024, Greg PFISTER. MIT License
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the “Software”), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
// the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import Combine
import SwiftUI

/// References:
///   - https://www.avanderlee.com/swift/appstorage-explained/
///   - https://www.hackingwithswift.com/quick-start/swiftui/observable-objects-environment-objects-and-published

@propertyWrapper public struct GPSKUserDefault<GPSKValue: Equatable>: DynamicProperty {
    @ObservedObject private var observer: GPSKObservableObject

    private let keyPath: ReferenceWritableKeyPath<GPSKUserDefaultValues, GPSKValue>
    private let userDefaultsService = GPSKUserDefaultsService.shared
    private let subject: CurrentValueSubject<GPSKValue, Never>

    public init(_ keyPath: ReferenceWritableKeyPath<GPSKUserDefaultValues, GPSKValue>) {
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

    public var wrappedValue: GPSKValue {
        get {
            subject.value
        }
        nonmutating set {
            userDefaultsService[keyPath] = newValue
        }
    }

    public var projectedValue: Binding<GPSKValue> {
        Binding(
            get: { subject.value },
            set: { wrappedValue = $0 }
        )
    }
}

// MARK: - Private

private extension GPSKUserDefault {
    final class GPSKObservableObject: ObservableObject {
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
