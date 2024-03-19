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

@propertyWrapper public struct GPSCKeychainSecKey<GPSCValue>: DynamicProperty {
    @ObservedObject private var keychainObserver: GPObservableObject

    private let keyPath: ReferenceWritableKeyPath<GPSCKeychainSecKeyValues, GPSCValue>
    private let keychainSecKeyService = GPSCKeychainSecKeyService.shared
    private let subject: CurrentValueSubject<GPSCValue, Never>

    public init(_ keyPath: ReferenceWritableKeyPath<GPSCKeychainSecKeyValues, GPSCValue>) {
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

    public var wrappedValue: GPSCValue {
        get {
            subject.value
        }
        nonmutating set {
            keychainSecKeyService[keyPath] = newValue
        }
    }

    public var projectedValue: Binding<GPSCValue> {
        Binding(
            get: { subject.value },
            set: { wrappedValue = $0 }
        )
    }
}

// MARK: - Private

private extension GPSCKeychainSecKey {
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
