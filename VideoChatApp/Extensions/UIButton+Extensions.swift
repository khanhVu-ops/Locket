//
//  UIButton+Extensions.swift
//  VideoChatApp
//
//  Created by Khanh Vu on 12/06/5 Reiwa.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

extension UIButton {
    func dimButton(){
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }

    func defaultTap() -> RxSwift.Observable<Void> {
        return self.rx.tap.ignoreFastTap()
    }
    
    func setColorImage(image: UIImage,color: UIColor) {
        let img = image.withRenderingMode(.alwaysTemplate)
        self.setBackgroundImage(img, for: .normal)
        self.tintColor = color
    }
}
