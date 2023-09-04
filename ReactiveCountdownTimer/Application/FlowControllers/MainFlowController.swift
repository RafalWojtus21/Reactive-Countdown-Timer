import UIKit
import RxSwift

protocol HasAppNavigation {
    var appNavigation: AppNavigation? { get }
}

protocol AppNavigation: AnyObject {
    func startApplication()
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
    
    // MARK: - Builders
    
    private lazy var timerScreenBuilder: TimerScreenBuilder = TimerScreenBuilderImpl(dependencies: extendedDependencies)

    // MARK: - Initialization
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: - AppNavigation
    
    func startApplication() {
        showtimerScreen()
    }
    
    private func showtimerScreen() {
        let codeReviewPlan: [CodeReviewSession] = [
            CodeReviewSession(title: "Feature A Review", duration: 20),
            CodeReviewSession(title: "Bug Fix Review", duration: 10),
            CodeReviewSession(title: "Refactoring Review", duration: 15),
            CodeReviewSession(title: "Documentation Review", duration: 19),
        ]
        let view = timerScreenBuilder.build(with: .init(codeReviewPlan: codeReviewPlan)).view
        dependencies.navigation.show(view: view, animated: false)
    }
}
