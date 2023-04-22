//
//  UIView+Extensions.swift
//  ChatApp
//
//  Created by Vu Khanh on 16/03/2023.
//

import Foundation
import UIKit
import FirebaseFirestore
extension UIView {
    func addBorder(borderWidth: CGFloat, borderColor: UIColor ) {
        layer.borderColor = borderColor.cgColor
        layer.borderWidth = borderWidth
    }
    
    func addShadow(color: UIColor = .black, opacity: Float = 1.0, radius: CGFloat = 0.0, offset: CGSize = CGSize.zero) {
        layer.shadowColor = color.cgColor
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
        layer.shadowOffset = offset
        layer.masksToBounds = false
    }
    
    func addConnerRadius(radius: CGFloat) {
        layer.cornerRadius = radius
        layer.masksToBounds = true
    }
    func convertToString(timestamp: Timestamp, formatter: String? = "hh:mm") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatter
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp.seconds))
//        let date = timestamp // replace with your own Firestore Date object
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
    func convertDurationToTime(duration: Double) -> String {
        let minutes = Int(duration / 60)
        let seconds = Int(Int(duration) - minutes * 60)
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
