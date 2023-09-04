//
//  TimerScreenMiddleware.swift
//  ReactiveCountdownTimer
//
//  Created by Rafał Wojtuś on 31/08/2023.
//

import RxSwift

final class TimerScreenMiddlewareImpl: TimerScreenMiddleware, TimerScreenCallback {
    typealias Dependencies = HasAppNavigation
    typealias Result = TimerScreenResult
    
    private let dependencies: Dependencies

    private let middlewareSubject = PublishSubject<Result>()
    var middlewareObservable: Observable<Result> { return middlewareSubject }
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    func process(result: Result) -> Observable<Result> {
        switch result {
        case .partialState(_): break
        case .effect(let effect):
            switch effect {
            case .codeReviewPlanFinished:
                break
            }
        }
        return .just(result)
    }
}
