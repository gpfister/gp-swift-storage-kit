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
import CryptoKit
import Foundation

/// References: https://www.avanderlee.com/swift/appstorage-explained/

// TODO: OSKSecKeyConvertible should include query parameters (to read)
// TODO: OSKSecKeyConvertible should include convertion to SecKey (to write)

public final class GPSKSecureEnclaveService {
    public static let shared = GPSKSecureEnclaveService()

    let valueChangedSubject = PassthroughSubject<PartialKeyPath<GPSKSecureEnclavePrivateKeyValues>, Never>()

    private let SecureEnclaveValues: GPSKSecureEnclavePrivateKeyValues

    init(SecureEnclaveValues: GPSKSecureEnclavePrivateKeyValues = .default) {
        self.SecureEnclaveValues = SecureEnclaveValues
    }

    subscript<GPSKValue>(_ keyPath: ReferenceWritableKeyPath<GPSKSecureEnclavePrivateKeyValues, GPSKValue>) -> GPSKValue {
        get { SecureEnclaveValues[keyPath: keyPath] }
        set {
            SecureEnclaveValues[keyPath: keyPath] = newValue
            valueChangedSubject.send(keyPath)
        }
    }
}
