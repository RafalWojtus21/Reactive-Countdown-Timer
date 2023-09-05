import UIKit
import RxSwift

protocol HasAppNavigation {
    var appNavigation: AppNavigation? { get }
}

protocol AppNavigation: AnyObject {
    func startApplication()
    func showTimerScreen()
    func showSummaryScreen(_ finishedSession: FinishedSessionPlan)
    func dismiss()
}

final class MainFlowController: AppNavigation {
    typealias Dependencies = HasNavigation
    typealias L = Localization.General
    
    struct ExtendedDependencies: Dependencies, HasAppNavigation, HasTimerManager {
        
        private let dependencies: Dependencies
        weak var appNavigation: AppNavigation?
        var navigation: Navigation { dependencies.navigation }
        let timerManager: TimerManager

        init(dependencies: Dependencies, appNavigation: AppNavigation) {
            self.dependencies = dependencies
            self.appNavigation = appNavigation
            self.timerManager = TimerManagerImpl()
        }
    }
    
    // MARK: - Properties
    
    private let dependencies: Dependencies
    // swiftlint:disable:next redundant_type_annotation
    private lazy var extendedDependencies: ExtendedDependencies = ExtendedDependencies(dependencies: dependencies, appNavigation: self)
    
    private let codeReviewPlan: [CodeReviewSession] = [
        CodeReviewSession(title: "Feature A Review", scheduledDuration: 88, actualDuration: nil),
        CodeReviewSession(title: "Bug Fix Review", scheduledDuration: 240, actualDuration: nil),
        CodeReviewSession(title: "Refactoring Review", scheduledDuration: 300, actualDuration: nil),
        CodeReviewSession(title: "Documentation Review", scheduledDuration: 60, actualDuration: nil),
    ]
    
    // MARK: - Builders
    
    private var timerScreenBuilder: TimerScreenBuilder?
    private lazy var summaryScreenBuilder: SummaryScreenBuilder = SummaryScreenBuilderImpl(dependencies: extendedDependencies)

    // MARK: - Initialization
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: - AppNavigation
    
    func startApplication() {
        showTimerScreen()
    }
    
    func showTimerScreen() {
        timerScreenBuilder = TimerScreenBuilderImpl(dependencies: extendedDependencies)
        guard let timerScreenBuilder else { return }
        let view = timerScreenBuilder.build(with: .init(codeReviewPlan: codeReviewPlan)).view
        dependencies.navigation.set(view: view, animated: false)
    }
    
    func showSummaryScreen(_ finishedSession: FinishedSessionPlan) {
        let view = summaryScreenBuilder.build(with: .init(finishedSession: finishedSession)).view
        dependencies.navigation.show(view: view, animated: false)
        timerScreenBuilder = nil
    }
    
    func dismiss() {
        dependencies.navigation.dismiss(completion: nil, animated: true)
    }
}
