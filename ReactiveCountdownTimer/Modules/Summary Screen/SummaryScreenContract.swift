//
//  SummaryScreenContract.swift
//  ReactiveCountdownTimer
//
//  Created by Rafał Wojtuś on 05/09/2023.
//

import RxSwift
import Foundation

enum SummaryScreenIntent {
    case viewLoaded
    case doneButtonIntent
}

struct SummaryScreenViewState: Equatable {
    var finishedSession: FinishedSessionPlan
    var sessionPlanDayLabelText: String {
        DateFormatter.dayMonthStringDateFormatter.string(from: finishedSession.startTime)
    }
    var sessionPlanTimeLabelText: String {
        let dateFormatter = DateFormatter.hourMinuteDateFormatter
        return "\(dateFormatter.string(from: finishedSession.startTime)) - \(dateFormatter.string(from: finishedSession.finishTime))"
    }
}

enum SummaryScreenEffect: Equatable {
    case showTimerScreen
}

struct SummaryScreenBuilderInput {
    let finishedSession: FinishedSessionPlan
}

protocol SummaryScreenCallback {
}

enum SummaryScreenResult: Equatable {
    case partialState(_ value: SummaryScreenPartialState)
    case effect(_ value: SummaryScreenEffect)
}

enum SummaryScreenPartialState: Equatable {
    case loadFinishedPlan(finishedPlan: FinishedSessionPlan)
    func reduce(previousState: SummaryScreenViewState) -> SummaryScreenViewState {
        var state = previousState
        switch self {
        case .loadFinishedPlan(finishedPlan: let finishedPlan):
            state.finishedSession = finishedPlan
        }
        return state
    }
}

protocol SummaryScreenBuilder {
    func build(with input: SummaryScreenBuilderInput) -> SummaryScreenModule
}

struct SummaryScreenModule {
    let view: SummaryScreenView
    let callback: SummaryScreenCallback
}

protocol SummaryScreenView: BaseView {
    var intents: Observable<SummaryScreenIntent> { get }
    func render(state: SummaryScreenViewState)
}

protocol SummaryScreenPresenter: AnyObject, BasePresenter {
    func bindIntents(view: SummaryScreenView, triggerEffect: PublishSubject<SummaryScreenEffect>) -> Observable<SummaryScreenViewState>
}

protocol SummaryScreenInteractor: BaseInteractor {
    func loadFinishedPlan() -> Observable<SummaryScreenResult>
}

protocol SummaryScreenMiddleware {
    var middlewareObservable: Observable<SummaryScreenResult> { get }
    func process(result: SummaryScreenResult) -> Observable<SummaryScreenResult>
}
