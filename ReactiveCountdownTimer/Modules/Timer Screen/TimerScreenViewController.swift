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
    
    private var sessionTrackerSubject = PublishSubject<[TimerScreen.Row]>()
    private var currentSessionIndexSubject = BehaviorSubject<Int>(value: 0)
    
    private lazy var sessionContentView: UIView = {
        let view = UIView(backgroundColor: .secondaryColor)
        view.layer.cornerRadius = 20
        return view
    }()
    
    private lazy var currentSessionNameLabel: UILabel = {
        let label = UILabel()
        label.font = .openSansSemiBold32
        label.textColor = .black
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
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
    
    private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.rowHeight = 80
        tableView.register(SessionTrackerCell.self)
        tableView.allowsSelection = true
        return tableView
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
        _intents.subject.onNext(.viewLoaded)
    }
    
    private func layoutView() {
        view.backgroundColor = .primaryColor
        view.addSubview(sessionContentView)
        sessionContentView.addSubview(currentSessionNameLabel)
        sessionContentView.addSubview(circularProgressBar)
        circularProgressBar.addSubview(timeLeftLabel)
        sessionContentView.addSubview(tableView)
        view.addSubview(timerControlView)
        view.addSubview(eventControlView)
        
        sessionContentView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalToSuperview().multipliedBy(0.8)
        }
        
        currentSessionNameLabel.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(50)
            $0.height.equalTo(50)
        }
        
        timeLeftLabel.snp.makeConstraints {
            $0.center.equalTo(circularProgressBar.snp.center)
            $0.width.equalTo(circularProgressBar.snp.width).inset(12)
        }
        
        circularProgressBar.snp.makeConstraints {
            $0.top.equalTo(currentSessionNameLabel.snp.bottom).offset(24)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(300)
        }
        
        timerControlView.snp.makeConstraints {
            $0.bottom.equalTo(eventControlView.snp.top).offset(-12)
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
        
        eventControlView.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(26)
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
        
        tableView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalTo(circularProgressBar.snp.bottom).offset(24)
            $0.height.equalTo(160)
        }
    }
    
    private func bindControls() {
        sessionTrackerSubject
            .bind(to: tableView.rx.items(cellIdentifier: SessionTrackerCell.reuseIdentifier, cellType: SessionTrackerCell.self)) { _, item, cell in
                cell.configure(with: SessionTrackerCell.ViewModel(sessionName: item.session.title, duration: item.session.scheduledDuration, isSelected: item.isSelected))
            }
            .disposed(by: bag)
        
        currentSessionIndexSubject
            .distinctUntilChanged()
            .skip(1)
            .subscribe(onNext: { [weak self] currentSessionIndex in
                guard let self else { return }
                let indexPath = IndexPath(row: currentSessionIndex, section: 0)
                self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
            })
            .disposed(by: bag)
        
        let startButtonIntent = startButton.rx.tap.map { Intent.startButtonIntent }
        let pauseButtonIntent = pauseButton.rx.tap.map {
            self.circularProgressBar.pauseAnimation()
            return Intent.pauseButtonIntent
        }
        let resumeButtonIntent = resumeButton.rx.tap.map {
            self.circularProgressBar.resumeAnimation()
            return Intent.resumeButtonIntent
        }
        
        let nextButtonIntent = nextEventButton.rx.tap.map {
            self.circularProgressBar.removeAnimation()
            return Intent.nextButtonIntent
        }
        
        Observable.merge(startButtonIntent, pauseButtonIntent, resumeButtonIntent, nextButtonIntent)
            .bind(to: _intents.subject)
            .disposed(by: bag)
    }
    
    private func trigger(effect: Effect) {
        switch effect {
        case .codeReviewPlanFinished(let plan):
            break
        }
    }
    
    func render(state: ViewState) {
        startButton.isHidden = !state.isStartButtonVisible
        nextEventButton.isHidden = !state.isNextButtonVisible
        pauseButton.isHidden = !state.isPauseButtonVisible
        pauseButton.isEnabled = state.isPauseButtonEnabled
        resumeButton.isHidden = !state.isResumeButtonVisible
        resumeButton.isEnabled = state.isResumeButtonEnabled
        
        if state.shouldChangeTable {
            sessionTrackerSubject.onNext(state.codeReviewSessions)
        }
        
        currentSessionIndexSubject.onNext(state.currentSessionIndex)
                
        if state.shouldChangeSessionName {
            currentSessionNameLabel.text = state.codeReviewSessions[state.currentSessionIndex].session.title
        }
        
        timeLeftLabel.text = "\(state.timeLeft)" + "s"
        if state.shouldChangeAnimation {
            circularProgressBar.setProgress(duration: Float(state.animationDuration))
        }
    }
}
