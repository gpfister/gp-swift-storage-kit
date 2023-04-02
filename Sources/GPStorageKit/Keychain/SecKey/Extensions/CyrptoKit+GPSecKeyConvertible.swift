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

import CryptoKit
import Foundation

/// Reference: https://developer.apple.com/documentation/cryptokit/storing_cryptokit_keys_in_the_keychain

extension P256.Signing.PrivateKey: GPSecKeyConvertible {}
extension P256.KeyAgreement.PrivateKey: GPSecKeyConvertible {}
extension P384.Signing.PrivateKey: GPSecKeyConvertible {}
extension P384.KeyAgreement.PrivateKey: GPSecKeyConvertible {}
extension P521.Signing.PrivateKey: GPSecKeyConvertible {}
extension P521.KeyAgreement.PrivateKey: GPSecKeyConvertible {}
