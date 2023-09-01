//
//  TimerScreenPresenter.swift
//  ReactiveCountdownTimer
//
//  Created by Rafał Wojtuś on 31/08/2023.
//

import RxSwift

final class TimerScreenPresenterImpl: TimerScreenPresenter {
    typealias View = TimerScreenView
    typealias ViewState = TimerScreenViewState
    typealias Middleware = TimerScreenMiddleware
    typealias Interactor = TimerScreenInteractor
    typealias Effect = TimerScreenEffect
    typealias Result = TimerScreenResult
    
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
            case .startButtonIntent:
                return .merge(interactor.triggerFirstSession(),
                              interactor.getRemainingTime())
            case .pauseButtonIntent:
                return interactor.pauseTimer()
            case .resumeButtonIntent:
                return interactor.resumeTimer()
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
