//
//  TimerScreenContract.swift
//  ReactiveCountdownTimer
//
//  Created by Rafał Wojtuś on 31/08/2023.
//

import RxSwift

enum TimerScreen {
    
    struct Row: Equatable {
        let session: CodeReviewSession
        let isSelected: Bool
    }
    
    enum IntervalState {
        case notStarted
        case running
        case paused
        case finished
    }
}

enum TimerScreenIntent {
    case viewLoaded
    case startButtonIntent
    case pauseButtonIntent
    case resumeButtonIntent
    case nextButtonIntent
}

struct TimerScreenViewState: Equatable {
    var shouldChangeSessionName = false
    var shouldChangeTable = false
    var codeReviewSessions: [TimerScreen.Row] = []
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
    var timeLeft: Int
}

enum TimerScreenEffect: Equatable {
    case codeReviewPlanFinished(_: FinishedSessionPlan)
}

struct TimerScreenBuilderInput {
    let codeReviewPlan: [CodeReviewSession]
}

protocol TimerScreenCallback {
}

enum TimerScreenResult: Equatable {
    case partialState(_ value: TimerScreenPartialState)
    case effect(_ value: TimerScreenEffect)
}

enum TimerScreenPartialState: Equatable {
    case loadSessions(sessions: [CodeReviewSession])
    case updateIntervalStatte(intervalState: TimerScreen.IntervalState)
    case triggerAnimation(duration: Int)
    case setTimeLeftValue(timeLeft: Int)
    case setCurrentSessionIndex(currentIndex: Int)
    case idle
    func reduce(previousState: TimerScreenViewState) -> TimerScreenViewState {
        var state = previousState
        state.shouldChangeAnimation = false
        state.shouldChangeSessionName = false
        switch self {
        case .loadSessions(sessions: let sessions):
            state.codeReviewSessions = sessions.compactMap { TimerScreen.Row(session: $0, isSelected: false) }
            state.shouldChangeSessionName = true
            state.shouldChangeTable = true
        case .updateIntervalStatte(intervalState: let intervalState):
            state.intervalState = intervalState
        case .triggerAnimation(duration: let duration):
            state.shouldChangeAnimation = true
            state.animationDuration = duration
        case .setTimeLeftValue(timeLeft: let timeLeft):
            state.timeLeft = timeLeft
        case .setCurrentSessionIndex(currentIndex: let currentIndex):
            state.currentSessionIndex = currentIndex
            state.shouldChangeSessionName = true
            state.shouldChangeTable = true
            state.codeReviewSessions = state.codeReviewSessions.enumerated().compactMap({ index, row in
                TimerScreen.Row(session: row.session, isSelected: index == currentIndex)
            })
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
    func loadSessions() -> Observable<TimerScreenResult>
    func triggerFirstSession() -> Observable<TimerScreenResult>
    func getRemainingTime() -> Observable<TimerScreenResult>
    func pauseTimer() -> Observable<TimerScreenResult>
    func resumeTimer() -> Observable<TimerScreenResult>
    func triggerNextSession() -> Observable<TimerScreenResult>
}

protocol TimerScreenMiddleware {
    var middlewareObservable: Observable<TimerScreenResult> { get }
    func process(result: TimerScreenResult) -> Observable<TimerScreenResult>
}
