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
    
//    func roundCorners(radius: CGFloat) {
//        let rect = CGRect(origin: .zero, size: self.size)
//        UIGraphicsBeginImageContextWithOptions(self.size, false, 1.0)
//        let path = UIBezierPath(roundedRect: rect, cornerRadius: radius)
//        path.addClip()
//        self.draw(in: rect)
//        let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return roundedImage!
//    }
}
