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

import Foundation

enum GPSKSecureEnclaveError: Error {
    case unableToRead(message: String)
    case unableToWrite(message: String)
    case unableToDelete(message: String)
    case unableToParseKeyRepresentation(error: Error)
}

extension GPSKSecureEnclaveError: CustomStringConvertible {
    var description: String {
        switch self {
        case let .unableToRead(message: message):
            "Unable to read key: \(message)"
        case let .unableToWrite(message: message):
            "Unable to write key: \(message)"
        case let .unableToDelete(message: message):
            "Unable to delete key: \(message)"
        case let .unableToParseKeyRepresentation(error: error):
            "Unable to parse key representation: \(error.localizedDescription)"
        }
    }
}

extension GPSKSecureEnclaveError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case let .unableToRead(message: message):
            String(
                format: NSLocalizedString(
                    "Unable to read key: %@",
                    comment: "Unable to read key error"
                ),
                message
            )
        case let .unableToWrite(message: message):
            String(
                format: NSLocalizedString(
                    "Unable to write key: %@",
                    comment: "Unable to write key error"
                ),
                message
            )
        case let .unableToDelete(message: message):
            String(
                format: NSLocalizedString(
                    "Unable to delete key: %@",
                    comment: "Unable to delete key error"
                ),
                message
            )
        case let .unableToParseKeyRepresentation(error: error):
            String(
                format: NSLocalizedString(
                    "Unable to parse key representation: %@",
                    comment: "Unable to parse key representation error"
                ),
                error.localizedDescription
            )
        }
    }
}
