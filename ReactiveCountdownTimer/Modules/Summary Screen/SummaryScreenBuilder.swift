//
//  SummaryScreenBuilder.swift
//  ReactiveCountdownTimer
//
//  Created by Rafał Wojtuś on 05/09/2023.
//

import UIKit
import RxSwift

final class SummaryScreenBuilderImpl: SummaryScreenBuilder {
    typealias Dependencies = SummaryScreenInteractorImpl.Dependencies & SummaryScreenMiddlewareImpl.Dependencies
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
        
    func build(with input: SummaryScreenBuilderInput) -> SummaryScreenModule {
        let interactor = SummaryScreenInteractorImpl(dependencies: dependencies, finishedPlan: input.finishedSession)
        let middleware = SummaryScreenMiddlewareImpl(dependencies: dependencies)
        let presenter = SummaryScreenPresenterImpl(interactor: interactor, middleware: middleware, initialViewState: SummaryScreenViewState(finishedSession: input.finishedSession))
        let view = SummaryScreenViewController(presenter: presenter)
        return SummaryScreenModule(view: view, callback: middleware)
    }
}
