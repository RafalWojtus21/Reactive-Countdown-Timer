//
//  TimerScreenViewController.swift
//  ReactiveCountdownTimer
//
//  Created by Rafał Wojtuś on 31/08/2023.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class TimerScreenViewController: BaseViewController, TimerScreenView {
    typealias ViewState = TimerScreenViewState
    typealias Effect = TimerScreenEffect
    typealias Intent = TimerScreenIntent
    
    @IntentSubject() var intents: Observable<TimerScreenIntent>
    
    private let effectsSubject = PublishSubject<Effect>()
    private let bag = DisposeBag()
    private let presenter: TimerScreenPresenter
    
    init(presenter: TimerScreenPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        layoutView()
        bindControls()
        effectsSubject.subscribe(onNext: { [weak self] effect in self?.trigger(effect: effect) })
            .disposed(by: bag)
        presenter.bindIntents(view: self, triggerEffect: effectsSubject)
            .subscribe(onNext: { [weak self] state in self?.render(state: state) })
            .disposed(by: bag)
    }
    
    private func layoutView() {
        view.backgroundColor = .primaryColor
    }
    
    private func bindControls() {
    }
    
    private func trigger(effect: Effect) {
        switch effect {
        }
    }
    
    func render(state: ViewState) {
    }
}
