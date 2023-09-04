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
        
    func build(with input: TimerScreenBuilderInput) -> TimerScreenModule {
        let interactor = TimerScreenInteractorImpl(dependencies: dependencies, codeReviewSessions: input.codeReviewPlan)
        let middleware = TimerScreenMiddlewareImpl(dependencies: dependencies)
        let presenter = TimerScreenPresenterImpl(interactor: interactor, middleware: middleware, initialViewState: TimerScreenViewState(timeLeft: input.codeReviewPlan.first?.duration ?? 0))
        let view = TimerScreenViewController(presenter: presenter)
        return TimerScreenModule(view: view, callback: middleware)
    }
}
