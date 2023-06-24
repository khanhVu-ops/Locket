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
    
    func isValidPhoneNumber() -> Bool {
//        let phoneNumberRegex = "^(0\\d{9})|(?!0)\\d{10}$"
//
//        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneNumberRegex)
//        return phonePredicate.evaluate(with: self.removeAllSpace())
        let phone = self.removeAllSpace()
        if phone.first == "0" {
            return phone.count == 10
        } else {
            return phone.count == 9
        }
    }
    
    func toAttributedStringWithColor(color: UIColor) -> NSAttributedString {
        let attributedText = NSAttributedString(string: self, attributes: [NSAttributedString.Key.foregroundColor: color])
        return attributedText
    }
    
    func toAttributedStringWithUnderlineAndColor(underline: Bool = false, color: UIColor) -> NSAttributedString{
        let attributedString = NSMutableAttributedString(string: self)
        attributedString.addAttribute(.foregroundColor, value: color, range: NSRange.init(location: 0, length: attributedString.length))
        attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange.init(location: 0, length: attributedString.length))
        return attributedString
    }
    
    func addSpaceToPhoneNumber() -> String{
        var characters = Array(self)
        if self.isValidPhoneNumber() {
            if characters.first == "0" {
                characters.insert(" ", at: 4)
                characters.insert(" ", at: 8)
            } else {
                characters.insert(" ", at: 3)
                characters.insert(" ", at: 7)
            }
        }
        return String(characters)
    }
    
    func removeAllSpace() -> String {
        let stringWithoutSpaces = self.replacingOccurrences(of: " ", with: "")
        return stringWithoutSpaces
    }
    
    func trimSpaceAndNewLine() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func addCountryCode() -> String {
        var phone = self
        if self.first == "0" {
            phone.removeFirst()
        }
        return "+84" + phone
    }
}
