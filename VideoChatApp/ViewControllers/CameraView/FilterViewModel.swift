//
//  FilterViewModel.swift
//  FlowerClassification
//
//  Created by Khanh Vu on 19/07/5 Reiwa.
//

import Foundation
import UIKit
import Photos
class FilterViewModel: BaseViewController {
    func fetchFirstAssets(imageSize: CGSize, completion: @escaping (UIImage?)->Void)  {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        DispatchQueue.global(qos: .background).async {
            guard let result = PHAsset.fetchAssets(with: options).firstObject else {
                completion(nil)
                return
            }
            let key = "thumbnailFirst-\(result.localIdentifier)"
            if let cachedImage = ImageCache.shared.image(forKey: key) {
                completion(cachedImage)
            } else {
                let imageManager = PHImageManager.default()
                let thumbnailOptions = PHImageRequestOptions()
                thumbnailOptions.deliveryMode = .fastFormat
                thumbnailOptions.resizeMode = .exact
                thumbnailOptions.isNetworkAccessAllowed = false
                thumbnailOptions.isSynchronous = true
                
                imageManager.requestImage(for: result, targetSize: imageSize, contentMode: .aspectFill, options: thumbnailOptions) { (image, info) in
                    guard let image = image else {
                        completion(nil)
                        return
                    }
                    completion(image)
                    ImageCache.shared.setImage(image, forKey: key)
                }
            }
        }
    }
}
