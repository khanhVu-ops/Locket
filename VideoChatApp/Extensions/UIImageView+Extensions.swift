//
//  UIImageView+Extensions.swift
//  VideoChatApp
//
//  Created by Khanh Vu on 24/06/5 Reiwa.
//

import Foundation
import UIKit
import SDWebImage

extension UIImageView {
    func setImage(urlString: String, placeHolder: UIImage) {
        if let url = URL(string: urlString) {
            self.sd_setImage(with: url, placeholderImage: placeHolder)
        } else {
            self.image = placeHolder
        }
    }
}

extension UIImage {
    func resize(with size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
}
