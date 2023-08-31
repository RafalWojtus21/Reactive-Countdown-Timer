import UIKit

struct AppDependencies: MainFlowController.Dependencies {
    
    // MARK: - Properties
    
    let navigation: Navigation
    
    // MARK: - Initialization
    
    init(navigationController: UINavigationController) {
        navigation = MainNavigation(navigationController: navigationController)
    }
}
