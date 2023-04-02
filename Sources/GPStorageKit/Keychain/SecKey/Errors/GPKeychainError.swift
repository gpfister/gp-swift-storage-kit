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

import Foundation

enum GPKeychainError: Error {
    case unableToRead(String)
    case unableToWrite(String)
    case unableToDelete(String)
    case unableToParseSecKeyRepresentation(String)
    case unableToCreateSecKeyRepresentation(String)
}

extension GPKeychainError: CustomStringConvertible {
    var description: String {
        switch self {
        case let .unableToRead(message):
            return "Unable to read key: \(message)"
        case let .unableToWrite(message):
            return "Unable to write key: \(message)"
        case let .unableToDelete(message):
            return "Unable to delete key: \(message)"
        case let .unableToParseSecKeyRepresentation(message):
            return "Unable to parse SecKey representation: \(message)"
        case let .unableToCreateSecKeyRepresentation(message):
            return "Unable to create SecKey representation: \(message)"
        }
    }
}

extension GPKeychainError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .unableToRead(message):
            return String(
                format: NSLocalizedString(
                    "Unable to read key: %s",
                    comment: "Unable to read key error"
                ),
                message
            )
        case let .unableToWrite(message):
            return String(
                format: NSLocalizedString(
                    "Unable to write key: %s",
                    comment: "Unable to write key error"
                ),
                message
            )
        case let .unableToDelete(message):
            return String(
                format: NSLocalizedString(
                    "Unable to delete key: %s",
                    comment: "Unable to delete key error"
                ),
                message
            )
        case let .unableToParseSecKeyRepresentation(message):
            return String(
                format: NSLocalizedString(
                    "Unable to parse SecKey representation: %s",
                    comment: "Unable to parse SecKey representation error"
                ),
                message
            )
        case let .unableToCreateSecKeyRepresentation(message):
            return String(
                format: NSLocalizedString(
                    "Unable to create SecKey representation: %s",
                    comment: "Unable to create SecKey representation"
                ),
                message
            )
        }
    }
}
