//
//  TimerScreenInteractor.swift
//  ReactiveCountdownTimer
//
//  Created by Rafał Wojtuś on 31/08/2023.
//

import RxSwift

final class TimerScreenInteractorImpl: TimerScreenInteractor {
    
    // MARK: Properties
    
    typealias Dependencies = Any
    typealias Result = TimerScreenResult
    
    private let dependencies: Dependencies
    
    // MARK: Initialization

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: Public Implementation
    
    // MARK: Private Implementation
}
