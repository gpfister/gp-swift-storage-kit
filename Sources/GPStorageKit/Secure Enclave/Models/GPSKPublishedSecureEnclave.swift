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
/// Example when shared in multiple view, with reactive support
/// ```
/// import Combine
/// import OSKStorageKit
/// import SwiftUI
///
/// // Shared environment value definition
/// //
/// extension EnvironmentValues {
///     struct OSKTestUserDefaultKey: EnvironmentKey {
///         static var defaultValue = OSKTestUserDefaultKey()
///     }
///
///     var userDefaults: OSKTestUserDefaults {
///         get { self[OSKTestUserDefaultKey.self] }
///         set { self[OSKTestUserDefaultKey.self] = newValue }
///     }
/// }
///
/// // Define user default key
/// //
/// extension GPSKUserDefaultValues {
///     struct GPCounterKey: GPSKUserDefaultKey {
///         static let key = "counter"
///         static let defaultValue: Int = 0
///     }
///
///     public var counter: Int {
///         get { self[GPCounterKey.self, at: \.counter] }
///         set { self[GPCounterKey.self, at: \.counter] = newValue }
///     }
/// }
///
/// // This view will share to its subviews the user default catalog
/// //
/// struct OSKTestSplitView: View {
///     @ObservedObject var userDefaults = OSKTestUserDefaults()
///
///     var body: some View {
///         VStack {
///             Spacer()
///             OSKTestView()
///             Spacer()
///             OSKTestView()
///             Spacer()
///         }
///         .environment(\.userDefaults, userDefaults)
///     }
/// }
///
/// // This view uses its own view model, which will access the user defaults
/// //
/// struct OSKTestView: View {
///     @StateObject private var viewModel = OSKTestViewModel()
///
///     var body: some View {
///         VStack {
///             Text("\(viewModel.userDefaults.counter)")
///             HStack {
///                 Button { viewModel.userDefaults.counter += 1 } label: {
///                     Text("Increase")
///                 }
///                 .buttonStyle(OSKPrimaryRoundedRectangularButtonStyle())
///
///                 Spacer()
///
///                 Button { viewModel.userDefaults.counter -= 1 } label: {
///                     Text("Decrease")
///                 }
///                 .buttonStyle(OSKPrimaryRoundedRectangularButtonStyle())
///             }
///         }
///         .padding()
///     }
/// }
///
/// // Expose the user defaults to the view, and synchronize user defaults
/// // updates with this view model updates
/// //
/// class OSKTestViewModel: ObservableObject {
///     @Environment(\.testUserDefaultViewModel) var userDefaults
///
///     private var cancellables = Set<AnyCancellable>()
///
///     init() {
///         userDefaults.objectWillChange.sink { _ in
///             self.objectWillChange.send()
///         }
///         .store(in: &cancellables)
///     }
/// }
///
/// class OSKTestUserDefaults: ObservableObject {
///     @GPSKPublishedUserDefault(\.counter) var counter
///
///     private var cancellables = Set<AnyCancellable>()
///
///     init() {
///         $testCounter.sink { _ in
///             print("Value received")
///         }
///         .store(in: &cancellables)
///     }
/// }
///
/// struct OSKTestSplitView_Previews: PreviewProvider {
///     static var previews: some View {
///         OSKTestSplitView()
///     }
/// }
/// ```
///
@propertyWrapper public class GPSKPublishedSecureEnclave<GPSKValue> {
    private let keyPath: ReferenceWritableKeyPath<GPSKSecureEnclaveValues, GPSKValue>
    private let SecureEnclaveService = GPSKSecureEnclaveService.shared
    let subject: CurrentValueSubject<GPSKValue, Never>
    let publisher: AnyPublisher<GPSKValue, Never>
    private var cancellables = Set<AnyCancellable>()

    public init(_ keyPath: ReferenceWritableKeyPath<GPSKSecureEnclaveValues, GPSKValue>) {
        self.keyPath = keyPath
        subject = .init(SecureEnclaveService[keyPath])
        publisher = subject.eraseToAnyPublisher()
        SecureEnclaveService.valueChangedSubject
            .filter { akeyPath in
                akeyPath == keyPath
            }
            .eraseToAnyPublisher()
            .sink { _ in
                self.subject.send(self.SecureEnclaveService[keyPath])
            }
            .store(in: &cancellables)
    }

    deinit {
        for cancellable in cancellables {
            cancellable.cancel()
        }
    }

    public func update() {
        subject.send(SecureEnclaveService[keyPath])
    }

    @available(*, unavailable, message: "Wrapped value should not be used.")
    public var wrappedValue: GPSKValue {
        get { fatalError() }
        set { fatalError() }
    }

    public static subscript<GPEnclosingType: ObservableObject>(
        _enclosingInstance instance: GPEnclosingType,
        wrapped _: ReferenceWritableKeyPath<GPEnclosingType, GPSKValue>,
        storage storageKeyPath: ReferenceWritableKeyPath<GPEnclosingType, GPSKPublishedSecureEnclave>
    ) -> GPSKValue {
        get {
            instance[keyPath: storageKeyPath].subject.value
        }
        set {
            DispatchQueue.main.async {
                (instance.objectWillChange as! ObservableObjectPublisher).send()
            }
            instance[keyPath: storageKeyPath].subject.send(newValue)
            instance[keyPath: storageKeyPath].SecureEnclaveService[instance[keyPath: storageKeyPath].keyPath] = newValue
        }
    }

    public var projectedValue: AnyPublisher<GPSKValue, Never> { publisher }
}
