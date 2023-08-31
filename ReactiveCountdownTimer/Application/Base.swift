import UIKit

protocol BaseView {}

protocol BasePresenter {}

protocol BaseInteractor {}

class BaseViewController: UIViewController {
    var showNavigationController = false
    var animatedTransitioning: UIViewControllerAnimatedTransitioning?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(!showNavigationController, animated: animated)
        navigationController?.navigationBar.tintColor = .white
    }
    
    deinit {
        print("Deinit: \(self)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
}
