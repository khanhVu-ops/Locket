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
