//
//  TimerScreenInteractor.swift
//  ReactiveCountdownTimer
//
//  Created by Rafał Wojtuś on 31/08/2023.
//

import RxSwift

final class TimerScreenInteractorImpl: TimerScreenInteractor {
    
    // MARK: Properties
    
    typealias Dependencies = HasTimerManager
    typealias Result = TimerScreenResult
    
    private let dependencies: Dependencies
    private let codeReviewSessions: [CodeReviewSession]
    
    // MARK: Initialization

    init(dependencies: Dependencies, codeReviewSessions: [CodeReviewSession]) {
        self.dependencies = dependencies
        self.codeReviewSessions = codeReviewSessions
    }
    
    // MARK: Public Implementation
    
//    func triggerFirstSession() -> RxSwift.Observable<TimerScreenResult> {
//        guard let sessionDuration = codeReviewSessions.first?.duration else { return .just(.partialState(.idle)) }
//        dependencies.timerManager.setTimer(countdownValue: sessionDuration)
//        return .merge(.just(.partialState(.updateIntervalStatte(intervalState: .running))),
//                      .just(.partialState(.setAnimationDuration(duration: sessionDuration))))
//    }
    
    func triggerFirstSession() -> RxSwift.Observable<TimerScreenResult> {
        guard let sessionDuration = codeReviewSessions.first?.duration else { return .just(.partialState(.idle)) }
        dependencies.timerManager.start(countdownValue: sessionDuration)
        return .merge(.just(.partialState(.updateIntervalStatte(intervalState: .running))),
                      .just(.partialState(.setAnimationDuration(duration: sessionDuration))))
    }
    
    func getRemainingTime() -> Observable<TimerScreenResult> {
        dependencies.timerManager.countdownObserver
            .map { timeLeft in
                print("time left: \(timeLeft)")
                return .partialState(.setTimeLeftValue(timeLeft: timeLeft))
            }
    }
    
    func pauseTimer() -> RxSwift.Observable<TimerScreenResult> {
        dependencies.timerManager.pause()
        return .just(.partialState(.updateIntervalStatte(intervalState: .paused)))
    }

    func resumeTimer() -> RxSwift.Observable<TimerScreenResult> {
        dependencies.timerManager.resume()
        return .just(.partialState(.updateIntervalStatte(intervalState: .running)))
    }
    
    // MARK: Private Implementation
}
