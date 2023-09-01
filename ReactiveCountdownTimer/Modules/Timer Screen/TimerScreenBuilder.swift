//
//  TimerScreenBuilder.swift
//  ReactiveCountdownTimer
//
//  Created by Rafał Wojtuś on 31/08/2023.
//

import UIKit
import RxSwift

final class TimerScreenBuilderImpl: TimerScreenBuilder {
    typealias Dependencies = TimerScreenInteractorImpl.Dependencies & TimerScreenMiddlewareImpl.Dependencies
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    private let codeReviewSessions: [CodeReviewSession] = [
        CodeReviewSession(title: "Feature A Review", duration: 20),
        CodeReviewSession(title: "Bug Fix Review", duration: 10),
        CodeReviewSession(title: "Refactoring Review", duration: 15),
        CodeReviewSession(title: "Documentation Review", duration: 19),
    ]
        
    func build(with input: TimerScreenBuilderInput) -> TimerScreenModule {
        let interactor = TimerScreenInteractorImpl(dependencies: dependencies, codeReviewSessions: codeReviewSessions)
        let middleware = TimerScreenMiddlewareImpl(dependencies: dependencies)
        let presenter = TimerScreenPresenterImpl(interactor: interactor, middleware: middleware, initialViewState: TimerScreenViewState(codeReviewSessions: codeReviewSessions, timeLeft: codeReviewSessions.first?.duration ?? 0))
        let view = TimerScreenViewController(presenter: presenter)
        return TimerScreenModule(view: view, callback: middleware)
    }
}
