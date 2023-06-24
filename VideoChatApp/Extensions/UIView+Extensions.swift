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
    class var nibNameClass: String { return String(describing: self.self) }
    
    class var nibClass: UINib? {
        if Bundle.main.path(forResource: nibNameClass, ofType: "nib") != nil {
            return UINib(nibName: nibNameClass, bundle: nil)
        } else {
            return nil
        }
    }
    
    class func loadFromNib(nibName: String? = nil) -> Self? {
        return loadFromNib(nibName: nibName, type: self)
    }
    
    class func loadFromNib<T: UIView>(nibName: String? = nil, type: T.Type) -> T? {
        guard let nibViews = Bundle.main.loadNibNamed(nibName ?? self.nibNameClass, owner: nil, options: nil)
        else { return nil }
        
        return nibViews.filter({ (nibItem) -> Bool in
            return (nibItem as? T) != nil
        }).first as? T
    }
    
    func setCornerRadius(cornerRadius: CGFloat, borderWidth: CGFloat = 0, borderColor: UIColor? = nil) {
        layer.cornerRadius = cornerRadius
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor?.cgColor
        layer.masksToBounds = true
        clipsToBounds = true
    }
    
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
    
    func circleClip() {
        layer.cornerRadius = self.bounds.width/2
        layer.masksToBounds = true
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    func setCornerRadiusAndBorder(topLeftRadius: CGFloat, topRightRadius: CGFloat, bottomRightRadius: CGFloat, bottomLeftRadius: CGFloat, borderColor: UIColor, borderWidth: CGFloat) {
            let path = UIBezierPath()
            path.move(to: CGPoint(x: bounds.minX + topLeftRadius, y: bounds.minY))
            
            // Top right corner
            path.addArc(withCenter: CGPoint(x: bounds.maxX - topRightRadius, y: bounds.minY + topRightRadius),
                        radius: topRightRadius,
                        startAngle: CGFloat(-Double.pi / 2),
                        endAngle: 0,
                        clockwise: true)
            
            // Bottom right corner
            path.addArc(withCenter: CGPoint(x: bounds.maxX - bottomRightRadius, y: bounds.maxY - bottomRightRadius),
                        radius: bottomRightRadius,
                        startAngle: 0,
                        endAngle: CGFloat(Double.pi / 2),
                        clockwise: true)
            
            // Bottom left corner
            path.addArc(withCenter: CGPoint(x: bounds.minX + bottomLeftRadius, y: bounds.maxY - bottomLeftRadius),
                        radius: bottomLeftRadius,
                        startAngle: CGFloat(Double.pi / 2),
                        endAngle: CGFloat(Double.pi),
                        clockwise: true)
            
            // Top left corner
            path.addArc(withCenter: CGPoint(x: bounds.minX + topLeftRadius, y: bounds.minY + topLeftRadius),
                        radius: topLeftRadius,
                        startAngle: CGFloat(Double.pi),
                        endAngle: CGFloat(-Double.pi / 2),
                        clockwise: true)
            
            let maskLayer = CAShapeLayer()
            maskLayer.path = path.cgPath
            layer.mask = maskLayer
            
            let borderLayer = CAShapeLayer()
            borderLayer.path = path.cgPath
            borderLayer.lineWidth = borderWidth
            borderLayer.strokeColor = borderColor.cgColor
            borderLayer.fillColor = UIColor.clear.cgColor
        
            layer.insertSublayer(borderLayer, at: 0)
        }
}
