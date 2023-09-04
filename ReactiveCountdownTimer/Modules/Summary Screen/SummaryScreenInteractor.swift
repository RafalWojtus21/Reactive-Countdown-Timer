//
//  SummaryScreenInteractor.swift
//  ReactiveCountdownTimer
//
//  Created by Rafał Wojtuś on 05/09/2023.
//

import RxSwift

final class SummaryScreenInteractorImpl: SummaryScreenInteractor {
    
    // MARK: Properties
    
    typealias Dependencies = Any
    typealias Result = SummaryScreenResult
    
    private let dependencies: Dependencies
    private let finishedPlan: FinishedSessionPlan
    
    // MARK: Initialization

    init(dependencies: Dependencies, finishedPlan: FinishedSessionPlan) {
        self.dependencies = dependencies
        self.finishedPlan = finishedPlan
    }
    
    // MARK: Public Implementation
    
    func loadFinishedPlan() -> Observable<SummaryScreenResult> {
        return .just(.partialState(.loadFinishedPlan(finishedPlan: finishedPlan)))
    }
    
    // MARK: Private Implementation
}
