//
//  SummaryScreenPresenter.swift
//  ReactiveCountdownTimer
//
//  Created by Rafał Wojtuś on 05/09/2023.
//

import RxSwift

final class SummaryScreenPresenterImpl: SummaryScreenPresenter {
    typealias View = SummaryScreenView
    typealias ViewState = SummaryScreenViewState
    typealias Middleware = SummaryScreenMiddleware
    typealias Interactor = SummaryScreenInteractor
    typealias Effect = SummaryScreenEffect
    typealias Result = SummaryScreenResult
    
    private let interactor: Interactor
    private let middleware: Middleware
    
    private let initialViewState: ViewState
    
    init(interactor: Interactor, middleware: Middleware, initialViewState: ViewState) {
        self.interactor = interactor
        self.middleware = middleware
        self.initialViewState = initialViewState
    }
    
    func bindIntents(view: View, triggerEffect: PublishSubject<Effect>) -> Observable<ViewState> {
        let intentResults = view.intents.flatMap { [unowned self] intent -> Observable<Result> in
            switch intent {
            case .viewLoaded:
                return interactor.loadFinishedPlan()
            case .doneButtonIntent:
                return .just(.effect(.showTimerScreen))
            }
        }
        return Observable.merge(middleware.middlewareObservable, intentResults)
            .flatMap { self.middleware.process(result: $0) }
            .scan(initialViewState, accumulator: { previousState, result -> ViewState in
                switch result {
                case .partialState(let partialState):
                    return partialState.reduce(previousState: previousState)
                case .effect(let effect):
                    triggerEffect.onNext(effect)
                    return previousState
                }
            })
            .startWith(initialViewState)
            .distinctUntilChanged()
    }
}
