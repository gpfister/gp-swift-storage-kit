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
    case unableToRead(String)
    case unableToWrite(String)
    case unableToDelete(String)
    case unableToParseSecKeyRepresentation(String)
    case unableToCreateSecKeyRepresentation(String)
}

extension GPSKSecureEnclaveError: CustomStringConvertible {
    var description: String {
        switch self {
            case let .unableToRead(message):
                "Unable to read key: \(message)"
            case let .unableToWrite(message):
                "Unable to write key: \(message)"
            case let .unableToDelete(message):
                "Unable to delete key: \(message)"
            case let .unableToParseSecKeyRepresentation(message):
                "Unable to parse SecKey representation: \(message)"
            case let .unableToCreateSecKeyRepresentation(message):
                "Unable to create SecKey representation: \(message)"
        }
    }
}

extension GPSKSecureEnclaveError: LocalizedError {
    var errorDescription: String? {
        switch self {
            case let .unableToRead(message):
                String(
                    format: NSLocalizedString(
                        "Unable to read key: %s",
                        comment: "Unable to read key error"
                    ),
                    message
                )
            case let .unableToWrite(message):
                String(
                    format: NSLocalizedString(
                        "Unable to write key: %s",
                        comment: "Unable to write key error"
                    ),
                    message
                )
            case let .unableToDelete(message):
                String(
                    format: NSLocalizedString(
                        "Unable to delete key: %s",
                        comment: "Unable to delete key error"
                    ),
                    message
                )
            case let .unableToParseSecKeyRepresentation(message):
                String(
                    format: NSLocalizedString(
                        "Unable to parse SecKey representation: %s",
                        comment: "Unable to parse SecKey representation error"
                    ),
                    message
                )
            case let .unableToCreateSecKeyRepresentation(message):
                String(
                    format: NSLocalizedString(
                        "Unable to create SecKey representation: %s",
                        comment: "Unable to create SecKey representation"
                    ),
                    message
                )
        }
    }
}
