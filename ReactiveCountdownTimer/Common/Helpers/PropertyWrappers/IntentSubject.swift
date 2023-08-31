//
//  IntentSubject.swift
//  ReactiveCountdownTimer
//
//  Created by Rafał Wojtuś on 29/08/2023.
//

import Foundation
import RxSwift

@propertyWrapper
struct IntentSubject<T> {
    let subject: PublishSubject<T>
    
    init(subject: PublishSubject<T> = .init()) {
        self.subject = subject
    }
    
    var wrappedValue: Observable<T> { subject }
}
