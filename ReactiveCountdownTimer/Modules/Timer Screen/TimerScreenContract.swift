//
//  TimerScreenContract.swift
//  ReactiveCountdownTimer
//
//  Created by Rafał Wojtuś on 31/08/2023.
//

import RxSwift

enum TimerScreen {
    
    enum IntervalState {
        case notStarted
        case running
        case paused
        case finished
    }
}

enum TimerScreenIntent {
    case startButtonIntent
    case pauseButtonIntent
    case resumeButtonIntent
}

struct TimerScreenViewState: Equatable {
    let codeReviewSessions: [CodeReviewSession]
    var currentSessionIndex = 0
    var shouldChangeAnimation = false
    var animationDuration = 0
    var intervalState: TimerScreen.IntervalState = .notStarted
    var isStartButtonVisible: Bool { intervalState == .notStarted }
    var isNextButtonVisible: Bool { !isStartButtonVisible }
    var isPauseButtonVisible: Bool { intervalState == .running }
    var isPauseButtonEnabled: Bool { isPauseButtonVisible }
    var isResumeButtonVisible: Bool { intervalState == .paused }
    var isResumeButtonEnabled: Bool { isResumeButtonVisible }
    var currentSessionDuration: Int { codeReviewSessions[currentSessionIndex].duration }
    var timeLeft: Int
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
    case updateIntervalStatte(intervalState: TimerScreen.IntervalState)
    case setAnimationDuration(duration: Int)
    case setTimeLeftValue(timeLeft: Int)
    case idle
    func reduce(previousState: TimerScreenViewState) -> TimerScreenViewState {
        var state = previousState
        state.shouldChangeAnimation = false
        switch self {
        case .updateIntervalStatte(intervalState: let intervalState):
            state.intervalState = intervalState
        case .setAnimationDuration(duration: let duration):
            state.shouldChangeAnimation = true
            state.animationDuration = duration
        case .setTimeLeftValue(timeLeft: let timeLeft):
            state.timeLeft = timeLeft
        case .idle:
            break
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
    func triggerFirstSession() -> Observable<TimerScreenResult>
    func getRemainingTime() -> Observable<TimerScreenResult>
    func pauseTimer() -> Observable<TimerScreenResult>
    func resumeTimer() -> Observable<TimerScreenResult>
}

protocol TimerScreenMiddleware {
    var middlewareObservable: Observable<TimerScreenResult> { get }
    func process(result: TimerScreenResult) -> Observable<TimerScreenResult>
}
