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

import CryptoKit
import Foundation
import LocalAuthentication

/**
 * Extension to allow to save private key as SecKey object is KeyChain store
 * Reference: https://developer.apple.com/documentation/cryptokit/storing_cryptokit_keys_in_the_keychain
 */

public protocol GPSKSecureEnclavePrivateKeyConvertible {
    init(dataRepresentation: Data, authenticationContext: LAContext?) throws
    var dataRepresentation: Data { get }
}

extension GPSKSecureEnclavePrivateKeyConvertible {
    init(dataRepresentation: Data) throws {
        try self.init(dataRepresentation: dataRepresentation, authenticationContext: nil)
    }
}
