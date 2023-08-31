
import UIKit

protocol HasNavigation {
    var navigation: Navigation { get }
}

protocol Navigation {
    func set(view: BaseView, animated: Bool)
    func setTabBar(viewControllers: [UINavigationController], animated: Bool, selectedTab: Int)
    func show(view: BaseView, animated: Bool)
    func pop()
    func popToRootViewController(animated: Bool)
    func popToTargetViewController(controllerType: UIViewController.Type, animated: Bool)
    func present(view: BaseView, animated: Bool, completion: (() -> Void)?)
    func dismiss(completion: (() -> Void)?, animated: Bool)
}

final class MainNavigation: Navigation {
    
    // MARK: - Properties
    
    private let navigationController: UINavigationController
    
    private var topViewController: UIViewController? {
        var topVC: UIViewController? = navigationController.topViewController
        while topVC?.presentedViewController != nil {
            topVC = topVC?.presentedViewController
            if let navCon = topVC as? UINavigationController {
                topVC = navCon.topViewController
            }
        }
        return topVC
    }
    
    private var activeNavigationController: UINavigationController {
        guard let navCon = topViewController?.navigationController else {
            return navigationController
        }
        return navCon
    }
    
    // MARK: - Initialization
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    // MARK: - Set
    
    func set(view: BaseView, animated: Bool) {
        guard let viewController = view as? UIViewController else { return }
        navigationController.setViewControllers([viewController], animated: animated)
    }
    
    func setTabBar(viewControllers: [UINavigationController], animated: Bool, selectedTab: Int) {
        let tabBar = UITabBarController()
        tabBar.tabBar.tintColor = .primaryColor
        tabBar.tabBar.unselectedItemTintColor = .primaryColor.withAlphaComponent(0.4)
        tabBar.tabBar.backgroundColor = .secondaryColor
        tabBar.modalPresentationStyle = .fullScreen
        tabBar.setViewControllers(viewControllers, animated: true)
        tabBar.selectedIndex = selectedTab
        navigationController.setViewControllers([tabBar], animated: animated)
        navigationController.view.window?.rootViewController?.dismiss(animated: true)
    }

    // MARK: - Push
    
    func show(view: BaseView, animated: Bool ) {
        guard let viewController = view as? UIViewController else { return }
        viewController.modalPresentationStyle = .fullScreen
        if animated {
            activeNavigationController.show(viewController, sender: nil)
        } else {
            UIView.performWithoutAnimation {
                activeNavigationController.show(viewController, sender: nil)
            }
        }
    }
    
    func pop() {
        activeNavigationController.popViewController(animated: true)
    }
    
    func popToRootViewController(animated: Bool) {
        activeNavigationController.popToRootViewController(animated: animated)
    }
    
    func popToTargetViewController(controllerType: UIViewController.Type, animated: Bool) {
        let targetViewController = activeNavigationController.viewControllers.first { viewController in
            viewController.isKind(of: controllerType)
        }
        guard let targetViewController else { return }
        activeNavigationController.popToViewController(targetViewController, animated: animated)
    }
    
    // MARK: - Present
    
    func present(view: BaseView, animated: Bool, completion: (() -> Void)?) {
        guard let topViewController = topViewController else { return }
        if let alert = view as? UIAlertController {
            topViewController.present(alert, animated: true, completion: completion)
            return
        }
        guard let viewController = view as? UIViewController else { return }
        let navCon = view as? UINavigationController ?? UINavigationController.init(rootViewController: viewController)
        topViewController.present(navCon, animated: animated, completion: completion)
    }

    func dismiss(completion: (() -> Void)?, animated: Bool) {
        guard let presentedViewController = activeNavigationController.topViewController else { return }
        presentedViewController.dismiss(animated: animated, completion: completion)
    }
}
