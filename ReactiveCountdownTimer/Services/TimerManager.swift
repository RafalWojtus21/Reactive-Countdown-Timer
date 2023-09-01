//
//  CalendarService.swift
//  ReactiveCountdownTimer
//
//  Created by Rafał Wojtuś on 29/08/2023.
//

import Foundation
import RxSwift
import RxRelay

protocol HasTimerManager {
    var timerManager: TimerManager { get }
}

protocol TimerManager {
    func start(countdownValue: Int)
    func pause()
    func resume()
    func stop()
    var countdownObserver: Observable<Int> { get }
}

final class TimerManagerImpl: TimerManager {
    
    // MARK: Properties
    
    private let bag = DisposeBag()
    private let timerScheduler: SchedulerType
    private let countdownSubject = BehaviorSubject<Int>(value: 0)
    var countdownObserver: Observable<Int> { countdownSubject }
    private var timer: Disposable?
    private var startTime: Date?
    private var pausedTime: Date?
    private var currentEventDuration = 0
    
    
    // MARK: Initialization
    
    init(timerScheduler: SchedulerType = MainScheduler.instance) {
        self.timerScheduler = timerScheduler
    }
    
    // MARK: Public Implementation
    
    private var accumulatedTime: TimeInterval = 0
    
    func start(countdownValue: Int) {
        startTime = Date()
        accumulatedTime = 0
        countdownSubject.onNext(countdownValue)
        timer = Observable<Int>.interval(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe { [weak self] event in
                guard let self = self, let startTime = self.startTime else { return }
                let currentTime = Date()
                let elapsedTime = Int(currentTime.timeIntervalSince(startTime) + self.accumulatedTime)
                let remainingSeconds = max(countdownValue - elapsedTime, 0)
                self.countdownSubject.onNext(remainingSeconds)
                if remainingSeconds <= 0 {
                    self.stop()
                    self.countdownSubject.onNext(0)
                }
            }
    }
    
    func pause() {
        guard let startTime else { return }
        pausedTime = Date()
        accumulatedTime += Date().timeIntervalSince(startTime)
        timer?.dispose()
    }
    
    func resume() {
        guard let pausedTime else { return }
        let adjustedStartTime = Date().addingTimeInterval(-accumulatedTime)
        let timeDifference = adjustedStartTime.timeIntervalSince(pausedTime)
        self.startTime = Date().addingTimeInterval(timeDifference)
        self.pausedTime = nil
        try! start(countdownValue: countdownSubject.value())
    }
    
    func stop() {
        timer?.dispose()
        startTime = nil
        pausedTime = nil
        countdownSubject.onNext(0)
    }
}
