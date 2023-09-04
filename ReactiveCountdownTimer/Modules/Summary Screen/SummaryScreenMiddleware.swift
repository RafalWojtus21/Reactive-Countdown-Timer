//
//  SummaryScreenMiddleware.swift
//  ReactiveCountdownTimer
//
//  Created by Rafał Wojtuś on 05/09/2023.
//

import RxSwift

final class SummaryScreenMiddlewareImpl: SummaryScreenMiddleware, SummaryScreenCallback {
    typealias Dependencies = HasAppNavigation
    typealias Result = SummaryScreenResult
    
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
            case .showTimerScreen:
                dependencies.appNavigation?.showTimerScreen()
            }
        }
        return .just(result)
    }
}
