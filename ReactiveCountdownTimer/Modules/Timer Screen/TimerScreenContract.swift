//
//  TimerScreenContract.swift
//  ReactiveCountdownTimer
//
//  Created by Rafał Wojtuś on 31/08/2023.
//

import RxSwift

enum TimerScreenIntent {
}

struct TimerScreenViewState: Equatable {
}

enum TimerScreenEffect: Equatable {
}

struct TimerScreenBuilderInput {
}

protocol TimerScreenCallback {
}

enum TimerScreenResult: Equatable {
    case partialState(_ value: TimerScreenPartialState)
    case effect(_ value: TimerScreenEffect)
}

enum TimerScreenPartialState: Equatable {
    func reduce(previousState: TimerScreenViewState) -> TimerScreenViewState {
        var state = previousState
        switch self {
        }
        return state
    }
}

protocol TimerScreenBuilder {
    func build(with input: TimerScreenBuilderInput) -> TimerScreenModule
}

struct TimerScreenModule {
    let view: TimerScreenView
    let callback: TimerScreenCallback
}

protocol TimerScreenView: BaseView {
    var intents: Observable<TimerScreenIntent> { get }
    func render(state: TimerScreenViewState)
}

protocol TimerScreenPresenter: AnyObject, BasePresenter {
    func bindIntents(view: TimerScreenView, triggerEffect: PublishSubject<TimerScreenEffect>) -> Observable<TimerScreenViewState>
}

protocol TimerScreenInteractor: BaseInteractor {
}

protocol TimerScreenMiddleware {
    var middlewareObservable: Observable<TimerScreenResult> { get }
    func process(result: TimerScreenResult) -> Observable<TimerScreenResult>
}
