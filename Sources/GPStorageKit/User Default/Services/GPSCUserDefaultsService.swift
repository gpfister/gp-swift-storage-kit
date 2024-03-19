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

/// References: https://www.avanderlee.com/swift/appstorage-explained/

public class GPSCUserDefaultsService {
    public static var shared: GPSCUserDefaultsService {
        if let _instance { return _instance }
        else {
            _instance = .init()
            return _instance!
        }
    }

    private static var _instance: GPSCUserDefaultsService?

    let valueChangedSubject = PassthroughSubject<PartialKeyPath<GPSCUserDefaultValues>, Never>()

    private let userDefaultValues: GPSCUserDefaultValues

    init(userDefaultValues: GPSCUserDefaultValues = .default) {
        self.userDefaultValues = userDefaultValues
    }

    subscript<GPSCValue>(_ keyPath: ReferenceWritableKeyPath<GPSCUserDefaultValues, GPSCValue>) -> GPSCValue {
        get { userDefaultValues[keyPath: keyPath] }
        set {
            userDefaultValues[keyPath: keyPath] = newValue
            valueChangedSubject.send(keyPath)
        }
    }

    func resetAllData() {
        userDefaultValues.resetAllData()
    }

    func resetUserData() {
        userDefaultValues.resetUserData()
    }
}
