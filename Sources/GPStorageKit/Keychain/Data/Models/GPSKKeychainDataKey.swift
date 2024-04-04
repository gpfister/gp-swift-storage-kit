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
import Foundation

public protocol GPSKKeychainDataKey {
    associatedtype GPSKValue: Equatable
    
    static var service: String { get }
    static var defaultValue: Self.GPSKValue? { get }
    static var isLinkedToUserId: Bool { get }
    
    static func encoder(_ value: Self.GPSKValue?) -> Data?
    static func decoder(_ value: Data?) -> Self.GPSKValue?
}

public extension GPSKKeychainDataKey where GPSKValue == String {
    static func encoder(_ value: String?) -> Data? {
        guard let value else { return nil }
        return value.data(using: .utf8)
    }
    
    static func decoder(_ value: Data?) -> String? {
        guard let value else { return nil }
        return String(data: value, encoding: .utf8)
    }
}

public extension GPSKKeychainDataKey where GPSKValue == Data {
    static func encoder(_ value: Data?) -> Data? {
        return value
    }
    
    static func decoder(_ value: Data?) -> Data? {
        return value
    }
}

public extension GPSKKeychainDataKey where GPSKValue: Codable {
    static func encoder(_ value: GPSKValue?) -> Data? {
        guard let value else { return nil }
        return try? JSONEncoder().encode(value)
    }
    
    static func decoder(_ value: Data?) -> GPSKValue? {
        guard let value else { return nil }
        return try? JSONDecoder().decode(GPSKValue.self, from: value)
    }
}
