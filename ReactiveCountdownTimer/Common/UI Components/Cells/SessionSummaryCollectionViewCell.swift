//
//  SessionSummaryCollectionViewCell.swift
//  ReactiveCountdownTimer
//
//  Created by Rafał Wojtuś on 05/09/2023.
//

import UIKit
import SnapKit

class SessionSummaryCollectionViewCell: UICollectionViewCell, CollectionViewReusableCell {
    
    struct ViewModel {
        let sessionName: String
        let totalTime: Int
    }
    
    // MARK: Properties
    
    private lazy var mainView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [sessionNameLabel, totalTimeLabel])
        view.axis = .vertical
        view.backgroundColor = .quaternaryColor
        view.layer.cornerRadius = 12
        view.spacing = 4
        return view
    }()
    
    private lazy var sessionNameLabel: UILabel = {
        let label = UILabel()
        label.font = .openSansSemiBold20
        label.numberOfLines = 0
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private lazy var totalTimeLabel: PaddingLabel = generateResultLabel()
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(mainView)
        layoutViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Public Implementation
    
    func configure(with viewModel: ViewModel) {
        sessionNameLabel.text = viewModel.sessionName
        totalTimeLabel.text = "Total time: " + "\(Int.calculateFormattedDuration(duration: viewModel.totalTime))"
    }
    
    // MARK: Private Implementation
    
    private func layoutViews() {
        backgroundColor = .clear
        mainView.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(4)
            $0.top.bottom.equalToSuperview().inset(6)
        }
    }
    
    private func generateResultLabel() -> PaddingLabel {
        let label = PaddingLabel(withInsets: UIEdgeInsets(top: 0, left: 16, bottom: 8, right: 0))
        label.font = .openSansSemiBold14
        label.textColor = .white
        label.textAlignment = .left
        return label
    }
}
