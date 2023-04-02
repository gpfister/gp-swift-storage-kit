//
//  ios-oskey-dev
// Copyright (c) 2022-2023, Greg PFISTER. MIT License.
//

import CryptoKit
import Foundation

/**
 * Extension to allow to save private key as SecKey object is KeyChain store
 * Reference: https://developer.apple.com/documentation/cryptokit/storing_cryptokit_keys_in_the_keychain
 */

public protocol GPSecKeyConvertible /*: CustomStringConvertible */ {
    init(x963Representation: some ContiguousBytes) throws
    var x963Representation: Data { get }
}
