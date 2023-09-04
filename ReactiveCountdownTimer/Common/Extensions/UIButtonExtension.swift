//
//  UIButtonExtension.swift
//  ReactiveCountdownTimer
//
//  Created by Rafał Wojtuś on 31/08/2023.
//

import UIKit
import RxCocoa

enum ButtonStyle {
    case primary
    case quaternary
}

enum BarButtonStyle {
    case rightButtonItem
    case leftButtonItem
    case rightStringButtonItemWhite
    case rightStringButtonItemBlack
}

extension UIButton {
    func apply(style: ButtonStyle, title: String) -> UIButton {
        setTitle(title, for: .normal)
        setTitleColor(.black, for: .normal)
        titleLabel?.font = .openSansSemiBold20
        layer.cornerRadius = 25
        switch style {
        case .primary:
            backgroundColor = isEnabled ? .secondaryColor : .white
            setTitleColor(.black, for: .normal)
        case .quaternary:
            backgroundColor = isEnabled ? .white.withAlphaComponent(0.9) : .tertiaryColorDisabled
        }
        return self
    }
}
