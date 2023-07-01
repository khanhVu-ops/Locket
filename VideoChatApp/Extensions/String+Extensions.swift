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
    
    func detectAndStyleLinks(foregroundColor: UIColor, fontSize: CGFloat) -> NSAttributedString {
        // Create an NSMutableAttributedString from the input string
        let attributedString = NSMutableAttributedString(string: self)
        attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: fontSize), range: NSRange(location: 0, length: self.utf16.count))
        attributedString.addAttribute(.foregroundColor, value: foregroundColor, range: NSRange(location: 0, length: self.utf16.count))
        // Create an NSDataDetector instance with the PhoneNumber and Link types
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue |
                                               NSTextCheckingResult.CheckingType.link.rawValue)
        // Enumerate all matches in the input string
        detector.enumerateMatches(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) { (result, _, _) in
            if let result = result {
                switch result.resultType {
                case .phoneNumber:
                    if let phoneNumber = result.phoneNumber, let url = URL(string: "tel://\(phoneNumber.replacingOccurrences(of: " ", with: ""))") {
                        // Apply attributes to the detected phone number
                        attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: result.range)
                        attributedString.addAttribute(.foregroundColor, value: UIColor.white, range: result.range)
                        attributedString.addAttribute(.link, value: url, range: result.range)
                        print("Detected phone number: \(phoneNumber)")
                    }
                case .link:
                    if let url = result.url {
                        // Apply attributes to the detected link
                        attributedString.addAttribute(.link, value: url, range: result.range)
                        attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: result.range)
                        attributedString.addAttribute(.foregroundColor, value: UIColor.white, range: result.range)
                    }
                default:
                    break
                }
            }
        }
        
        return attributedString
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
