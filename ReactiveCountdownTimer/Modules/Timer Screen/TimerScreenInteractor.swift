//
//  TimerScreenInteractor.swift
//  ReactiveCountdownTimer
//
//  Created by Rafał Wojtuś on 31/08/2023.
//

import RxSwift
import RxRelay
import Foundation

final class TimerScreenInteractorImpl: TimerScreenInteractor {
    
    // MARK: Properties
    
    typealias Dependencies = HasTimerManager
    typealias Result = TimerScreenResult
    
    private let dependencies: Dependencies
    private var codeReviewSessions: [CodeReviewSession]
    private let currentSessionTracker = BehaviorRelay<Int>(value: 0)
    private var startTime: Date?
    private var currentSessionStartTime = BehaviorRelay<Date?>(value: nil)

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
        startTime = Date()
        currentSessionStartTime.accept(Date())
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
        calculateLastSessionDuration()
        currentSessionStartTime.accept(Date())
        currentSessionTracker.accept(currentSessionTracker.value + 1)
        guard currentSessionTracker.value < codeReviewSessions.count else {
            return finishSession()
        }
        return handleCurrentSession(codeReviewSessions[currentSessionTracker.value])
    }
    
    private func calculateLastSessionDuration() {
        guard let sessionStartTime = currentSessionStartTime.value else { return }
        let sessionEndTime = Date()
        let actualTime = sessionEndTime.timeIntervalSince(sessionStartTime)
        codeReviewSessions[currentSessionTracker.value].actualDuration = Int(actualTime.rounded(.toNearestOrAwayFromZero))
    }
    
    // MARK: Private Implementation
    
    private func handleCurrentSession(_ session: CodeReviewSession) -> Observable<TimerScreenResult> {
        dependencies.timerManager.start(countdownValue: session.scheduledDuration)
        return .merge(.just(.partialState(.updateIntervalStatte(intervalState: .running))),
                      .just(.partialState(.triggerAnimation(duration: session.scheduledDuration))),
                      .just(.partialState(.setCurrentSessionIndex(currentIndex: currentSessionTracker.value))))
    }
    
    private func finishSession() -> Observable<TimerScreenResult> {
        let finishedSessionPlan = FinishedSessionPlan(sessions: codeReviewSessions, startTime: startTime ?? Date(), finishTime: Date())
        return .merge(.just(.partialState(.updateIntervalStatte(intervalState: .finished))),
                      .just(.effect(.codeReviewPlanFinished(finishedSessionPlan))) )
    }
}
