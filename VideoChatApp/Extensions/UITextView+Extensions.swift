//
//  UITextView+Extensions.swift
//  VideoChatApp
//
//  Created by Khanh Vu on 24/06/5 Reiwa.
//

import Foundation
import UIKit

extension UITextView {
    func setPlaceholder(_ placeholder: String) {
        let placeholderLabel = UILabel()
        placeholderLabel.text = placeholder
        placeholderLabel.font = self.font
        placeholderLabel.sizeToFit()
        placeholderLabel.tag = 999
        placeholderLabel.isHidden = !self.text.isEmpty
        
        self.addSubview(placeholderLabel)
        self.resizePlaceholderLabel()
        
        NotificationCenter.default.addObserver(self, selector: #selector(textChanged), name: UITextView.textDidChangeNotification, object: nil)
    }
    
    private func resizePlaceholderLabel() {
        if let placeholderLabel = self.viewWithTag(999) as? UILabel {
            placeholderLabel.frame.origin = CGPoint(x: 5, y: 8)
            placeholderLabel.frame.size = self.bounds.size
        }
    }
    
    @objc private func textChanged() {
        if let placeholderLabel = self.viewWithTag(999) as? UILabel {
            placeholderLabel.isHidden = !self.text.isEmpty
        }
    }
}
