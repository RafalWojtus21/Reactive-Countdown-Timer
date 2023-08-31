//
//  SceneDelegate.swift
//  ReactiveCountdownTimer
//
//  Created by Rafał Wojtuś on 29/08/2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    private var mainFlowController: AppNavigation?
    
    private lazy var navigationController: UINavigationController = {
        let navigationController = UINavigationController()
        return navigationController
    }()
    
    private lazy var calendarDependencies = AppDependencies(navigationController: navigationController)
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        mainFlowController = MainFlowController(dependencies: calendarDependencies)
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = navigationController
        self.window = window
        window.makeKeyAndVisible()
        mainFlowController?.startApplication()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
    }
}
