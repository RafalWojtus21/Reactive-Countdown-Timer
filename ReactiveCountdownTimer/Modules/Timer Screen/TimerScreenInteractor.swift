//
//  TimerScreenInteractor.swift
//  ReactiveCountdownTimer
//
//  Created by Rafał Wojtuś on 31/08/2023.
//

import RxSwift
import RxRelay

final class TimerScreenInteractorImpl: TimerScreenInteractor {
    
    // MARK: Properties
    
    typealias Dependencies = HasTimerManager
    typealias Result = TimerScreenResult
    
    private let dependencies: Dependencies
    private let codeReviewSessions: [CodeReviewSession]
    private let currentSessionTracker = BehaviorRelay<Int>(value: 0)
    
    // MARK: Initialization

    init(dependencies: Dependencies, codeReviewSessions: [CodeReviewSession]) {
        self.dependencies = dependencies
        self.codeReviewSessions = codeReviewSessions
    }
    
    // MARK: Public Implementation
    
    func loadSessions() -> Observable<TimerScreenResult> {
        return .just(.partialState(.loadSessions(sessions: codeReviewSessions)))
    }
    
    func triggerFirstSession() -> Observable<TimerScreenResult> {
        guard let firstSession = codeReviewSessions.first else { return .just(.partialState(.idle)) }
        return handleCurrentSession(firstSession)
    }
    
    func getRemainingTime() -> Observable<TimerScreenResult> {
        dependencies.timerManager.countdownObserver
            .map { timeLeft in
                return .partialState(.setTimeLeftValue(timeLeft: timeLeft))
            }
    }
    
    func pauseTimer() -> Observable<TimerScreenResult> {
        dependencies.timerManager.pause()
        return .just(.partialState(.updateIntervalStatte(intervalState: .paused)))
    }

    func resumeTimer() -> Observable<TimerScreenResult> {
        dependencies.timerManager.resume()
        return .just(.partialState(.updateIntervalStatte(intervalState: .running)))
    }
    
    func triggerNextSession() -> Observable<TimerScreenResult> {
        dependencies.timerManager.stop()
        currentSessionTracker.accept(currentSessionTracker.value + 1)
        guard currentSessionTracker.value < codeReviewSessions.count else {
            return finishSession()
        }
        return handleCurrentSession(codeReviewSessions[currentSessionTracker.value])
    }
    
    
    // MARK: Private Implementation
    
    private func handleCurrentSession(_ session: CodeReviewSession) -> Observable<TimerScreenResult> {
        dependencies.timerManager.start(countdownValue: session.duration)
        return .merge(.just(.partialState(.updateIntervalStatte(intervalState: .running))),
                      .just(.partialState(.triggerAnimation(duration: session.duration))),
                      .just(.partialState(.setCurrentSessionIndex(currentIndex: currentSessionTracker.value))))
    }
    
    private func finishSession() -> Observable<TimerScreenResult> {
        return .merge(.just(.effect(.codeReviewPlanFinished)),
                      .just(.partialState(.updateIntervalStatte(intervalState: .finished))))
    }
}
