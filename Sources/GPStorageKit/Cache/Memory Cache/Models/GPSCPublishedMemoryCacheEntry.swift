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

/// Wraps a user default to be published inside an ``ObserableObject``.
///
@propertyWrapper public class GPSCPublishedMemoryCacheEntry<GPSCValue> {
    private let keyPath: ReferenceWritableKeyPath<GPSCMemoryCacheValues, GPSCValue>
    private let memoryCacheService = GPSCMemoryCacheService.shared
    private let subject: CurrentValueSubject<GPSCValue, Never>
    private let publisher: AnyPublisher<GPSCValue, Never>
    private var cancellables = Set<AnyCancellable>()

    public init(_ keyPath: ReferenceWritableKeyPath<GPSCMemoryCacheValues, GPSCValue>) {
        self.keyPath = keyPath
        subject = .init(memoryCacheService[keyPath])
        publisher = subject.eraseToAnyPublisher()
        memoryCacheService.valueChangedSubject
            .filter { akeyPath in
                akeyPath == keyPath
            }
            .eraseToAnyPublisher()
            .sink { _ in
                self.subject.send(self.memoryCacheService[keyPath])
            }
            .store(in: &cancellables)
    }

    deinit {
        for cancellable in cancellables {
            cancellable.cancel()
        }
    }

    public func update() {
        subject.send(memoryCacheService[keyPath])
    }

    @available(*, unavailable, message: "Wrapped value should not be used.")
    public var wrappedValue: GPSCValue {
        get { fatalError() }
        set { fatalError() }
    }

    public static subscript<GPEnclosingType: ObservableObject>(
        _enclosingInstance instance: GPEnclosingType,
        wrapped _: ReferenceWritableKeyPath<GPEnclosingType, GPSCValue>,
        storage storageKeyPath: ReferenceWritableKeyPath<GPEnclosingType, GPSCPublishedMemoryCacheEntry>
    ) -> GPSCValue {
        get {
            instance[keyPath: storageKeyPath].subject.value
        }
        set {
            DispatchQueue.main.async {
                (instance.objectWillChange as! ObservableObjectPublisher).send()
            }
            instance[keyPath: storageKeyPath].subject.send(newValue)
            instance[keyPath: storageKeyPath].memoryCacheService[instance[keyPath: storageKeyPath].keyPath] = newValue
        }
    }

    public var projectedValue: AnyPublisher<GPSCValue, Never> { publisher }
}
