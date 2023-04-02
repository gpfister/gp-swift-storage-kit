//
//  CounterViewModel.swift
//  gp-swift-storage-kit-test
//
//  Created by Greg PFISTER on 03/04/2023.
//

import Combine
import Foundation
import GPStorageKit

class GPCounterViewModel: ObservableObject {
    @GPPublishedUserDefault(\.counter) var counter

    private var cancellables = Set<AnyCancellable>()

    init() {}

    func increase() {
        counter = (counter ?? 0) + 1
//        counter += 1
    }

    func decrease() {
        guard let counter else { return }
        if counter > 0 { self.counter = counter - 1 }
//        if counter != 0 { counter -= 1 }
    }
}
