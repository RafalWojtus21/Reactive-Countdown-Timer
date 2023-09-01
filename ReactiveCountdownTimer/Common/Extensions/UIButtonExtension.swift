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
        setTitleColor(.tertiaryColor, for: .normal)
        titleLabel?.font = .openSansSemiBold20
        switch style {
        case .primary:
            backgroundColor = isEnabled ? .primaryColor : .tertiaryColorDisabled
            layer.cornerRadius = 25
        case .quaternary:
            layer.cornerRadius = 25
            backgroundColor = isEnabled ? .quaternaryColor : .white
        }
        return self
    }
}
