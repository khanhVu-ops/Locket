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
    
    func convertImageToURL() -> URL? {
        // Get the image data
        guard let imageData = self.jpegData(compressionQuality: 1.0) else {
            return nil
        }
        
        // Create a temporary file URL
        let temporaryDirectory = NSTemporaryDirectory()
        let fileName = ProcessInfo.processInfo.globallyUniqueString + ".jpg"
        let fileURL = URL(fileURLWithPath: temporaryDirectory).appendingPathComponent(fileName)
        
        // Write the image data to the temporary file URL
        do {
            try imageData.write(to: fileURL)
            return fileURL
        } catch {
            print("Error writing image data: \(error)")
            return nil
        }
    }
}
