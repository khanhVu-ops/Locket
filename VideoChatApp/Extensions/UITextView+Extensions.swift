//
//  UITextView+Extensions.swift
//  VideoChatApp
//
//  Created by Khanh Vu on 24/06/5 Reiwa.
//

import Foundation
import UIKit

extension UITextView {
    func getSize() -> CGSize {
        let fixedWidth = self.frame.size.width
        let newSize = self.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        return newSize
    }
}
