//
//  String+Extensions.swift
//  VideoChatApp
//
//  Created by Khanh Vu on 14/04/5 Reiwa.
//

import Foundation
import UIKit
import RxSwift

extension String {
    func isURL() -> Bool {
        // Regular expression pattern để kiểm tra xem văn bản có phải là URL hay không
        let pattern = "(?i)\\b((?:https?://|www\\.)\\S+)\\b"
        
        if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
            let range = NSRange(location: 0, length: self.utf16.count)
            let matches = regex.matches(in: self, options: [], range: range)
            return matches.count > 0
        }
        return false
    }
}
