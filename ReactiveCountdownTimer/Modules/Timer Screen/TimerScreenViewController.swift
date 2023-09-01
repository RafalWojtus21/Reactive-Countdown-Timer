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
    
    private lazy var timeLeftLabel: UILabel = {
        let label = UILabel()
        label.font = .openSansSemiBold32
        label.textColor = .black
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private lazy var startButton = UIButton().apply(style: .primary, title: "Start")
    
    private lazy var nextEventButton: UIButton = {
        let button = UIButton().apply(style: .primary, title: "Next")
        button.isHidden = true
        return button
    }()
    
    private lazy var eventControlView: UIView = {
        let view = UIView(backgroundColor: .clear)
        view.addSubview(startButton)
        view.addSubview(nextEventButton)
        return view
    }()
    
    private lazy var timerControlView: UIView = {
        let view = UIView(backgroundColor: .clear)
        view.addSubview(pauseButton)
        view.addSubview(resumeButton)
        return view
    }()
    
    private lazy var pauseButton: UIButton = {
        let button = UIButton().apply(style: .quaternary, title: "Pause")
        button.isHidden = true
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        return button
    }()
    
    private lazy var resumeButton: UIButton = {
        let button = UIButton().apply(style: .quaternary, title: "Resume")
        button.isHidden = true
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        return button
    }()
    
    private lazy var circularProgressBar = CircularProgressBarView()
    
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
        view.backgroundColor = .secondaryColor
        view.addSubview(timeLeftLabel)
        view.addSubview(circularProgressBar)
        view.addSubview(eventControlView)
        view.addSubview(timerControlView)
        
        timeLeftLabel.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(circularProgressBar.snp.top).offset(-16)
            $0.height.equalTo(32)
        }
        
        circularProgressBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(100)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(300)
        }
        
        eventControlView.snp.makeConstraints {
            $0.top.equalTo(circularProgressBar.snp.bottom).offset(12)
            $0.height.equalTo(50)
            $0.left.right.equalToSuperview()
        }
        
        startButton.snp.makeConstraints {
            $0.height.equalToSuperview()
            $0.left.right.equalToSuperview().inset(48)
        }
        
        nextEventButton.snp.makeConstraints {
            $0.height.equalToSuperview()
            $0.left.right.equalToSuperview().inset(48)
        }
        
        timerControlView.snp.makeConstraints {
            $0.top.equalTo(eventControlView.snp.bottom).offset(12)
            $0.height.equalTo(50)
            $0.left.right.equalToSuperview()
        }
        
        pauseButton.snp.makeConstraints {
            $0.height.equalToSuperview()
            $0.left.right.equalToSuperview().inset(48)
        }
        
        resumeButton.snp.makeConstraints {
            $0.height.equalToSuperview()
            $0.left.right.equalToSuperview().inset(48)
        }
    }
    
    private func bindControls() {
        let startButtonIntent = startButton.rx.tap.map { Intent.startButtonIntent }
        let pauseButtonIntent = pauseButton.rx.tap.map {
            self.circularProgressBar.pauseAnimation()
            return Intent.pauseButtonIntent
        }
        let resumeButtonIntent = resumeButton.rx.tap.map {
            self.circularProgressBar.resumeAnimation()
            return Intent.resumeButtonIntent
        }
        
        Observable.merge(startButtonIntent, pauseButtonIntent, resumeButtonIntent)
            .bind(to: _intents.subject)
            .disposed(by: bag)
    }
    
    private func trigger(effect: Effect) {
        switch effect {
        }
    }
    
    func render(state: ViewState) {
        startButton.isHidden = !state.isStartButtonVisible
        nextEventButton.isHidden = !state.isNextButtonVisible
        pauseButton.isHidden = !state.isPauseButtonVisible
        pauseButton.isEnabled = state.isPauseButtonEnabled
        resumeButton.isHidden = !state.isResumeButtonVisible
        resumeButton.isEnabled = state.isResumeButtonEnabled
        
        timeLeftLabel.text = "\(state.timeLeft)" + "s"
        if state.shouldChangeAnimation {
            circularProgressBar.setProgress(duration: Float(state.animationDuration))
        }
    }
}
