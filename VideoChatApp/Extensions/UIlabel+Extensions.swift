//
//  UIlabel+Extensions.swift
//  VideoChatApp
//
//  Created by Khanh Vu on 30/04/5 Reiwa.
//

import Foundation
import UIKit

extension UILabel {
    func setPadding(_ padding: UIEdgeInsets) {
            let textRect = self.textRect(forBounds: self.bounds, limitedToNumberOfLines: self.numberOfLines)
            let paddedRect = textRect.inset(by: padding)
            self.frame = paddedRect
        }
}
