//
//  SummaryScreenViewController.swift
//  ReactiveCountdownTimer
//
//  Created by Rafał Wojtuś on 05/09/2023.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class SummaryScreenViewController: BaseViewController, SummaryScreenView {
    typealias ViewState = SummaryScreenViewState
    typealias Effect = SummaryScreenEffect
    typealias Intent = SummaryScreenIntent
    typealias L = Localization.SummaryScreen
    
    @IntentSubject() var intents: Observable<SummaryScreenIntent>
    
    private let effectsSubject = PublishSubject<Effect>()
    private let bag = DisposeBag()
    private let presenter: SummaryScreenPresenter
    
    private var sessionPlanSummarySubject = PublishSubject<[CodeReviewSession]>()
    
    private lazy var sessionTimeStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [sessionDayLabel, sessionTimeLabel])
        view.axis = .vertical
        return view
    }()
    
    private lazy var sessionDayLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.openSansSemiBold20
        label.textColor = .lightGray
        label.textAlignment = .center
        return label
    }()
    
    private lazy var sessionTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.openSansSemiBold24
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private lazy var collectionViewContainer = UIView(backgroundColor: .clear)
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.itemSize = CGSize(width: Int(view.frame.width - 16) / 2, height: 140)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(SessionSummaryCollectionViewCell.self)
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    private lazy var doneButton = UIButton().apply(style: .primary, title: L.doneButtonTitle)
    
    init(presenter: SummaryScreenPresenter) {
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
        
        view.addSubview(sessionTimeStackView)
        view.addSubview(collectionViewContainer)
        collectionViewContainer.addSubview(collectionView)
        view.addSubview(doneButton)
        
        sessionTimeStackView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(80)
        }
        
        doneButton.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(48)
            $0.bottom.equalToSuperview().inset(36)
            $0.height.equalTo(48)
        }
        
        collectionView.snp.makeConstraints {
            $0.centerY.equalTo(view.snp.centerY).priority(.low)
            $0.top.greaterThanOrEqualToSuperview().priority(.high)
            $0.bottom.lessThanOrEqualToSuperview().priority(.high)
            $0.height.equalTo(collectionView.collectionViewLayout.collectionViewContentSize.height).priority(.medium)
            $0.left.right.equalToSuperview()
        }
        
        collectionViewContainer.snp.makeConstraints {
            $0.top.equalTo(sessionTimeStackView.snp.bottom).offset(12)
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(doneButton.snp.top).offset(-24)
        }
    }
    
    private func bindControls() {
        sessionPlanSummarySubject
            .bind(to: collectionView.rx.items(cellIdentifier: SessionSummaryCollectionViewCell.reuseIdentifier, cellType: SessionSummaryCollectionViewCell.self)) { _, item, cell in
                cell.configure(with: SessionSummaryCollectionViewCell.ViewModel(sessionName: item.title, totalTime: item.actualDuration ?? 0))
            }
            .disposed(by: bag)
        
        let doneButtonIntent = doneButton.rx.tap.map { Intent.doneButtonIntent }
        
        doneButtonIntent
            .bind(to: _intents.subject)
            .disposed(by: bag)
    }
    
    private func trigger(effect: Effect) {
        switch effect {
        case .showTimerScreen:
            break
        }
    }
    
    func render(state: ViewState) {
        sessionPlanSummarySubject.onNext(state.finishedSession.sessions)
        sessionDayLabel.text = state.sessionPlanDayLabelText
        sessionTimeLabel.text = state.sessionPlanTimeLabelText
        
        collectionViewContainer.layoutSubviews()
        collectionViewContainer.layoutIfNeeded()
        
        collectionView.snp.updateConstraints {
            $0.height.equalTo(collectionView.collectionViewLayout.collectionViewContentSize.height).priority(.medium)
        }
    }
}
