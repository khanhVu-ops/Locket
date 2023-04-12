//
//  PhotosViewModel.swift
//  VideoChatApp
//
//  Created by Khanh Vu on 04/04/5 Reiwa.
//

import Foundation
import RxSwift
import RxCocoa
import Photos
import UIKit

enum AssetType {
    case video
    case image
}
class AssetModel {
    var type: PHAssetMediaType
    var asset: PHAsset
    var isSelected: Bool
    var thumbnail: UIImage
    var duration: Double
    
    init(type: PHAssetMediaType, asset: PHAsset, issSelected: Bool = false, thumbnail: UIImage, duration: Double = 0.0) {
        self.type = type
        self.asset = asset
        self.isSelected = issSelected
        self.thumbnail = thumbnail
        self.duration = duration
    }
}

class PhotosViewModel {
    var assetsFetchResults: PHFetchResult<PHAsset>!
    var imageManager: PHCachingImageManager!
    let imageCellSize = CGSize(width: (UIScreen.main.bounds.size.width-4)/3, height: (UIScreen.main.bounds.size.width-4)/3)
    var assetsBehavior = BehaviorRelay<[AssetModel]>(value: [])
    let imageCache = NSCache<NSString, UIImage>()
    
    func fetchAssets() {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]

        DispatchQueue.global(qos: .background).async {
            let results = PHAsset.fetchAssets(with: options)
            print(results.count)
            var newAsset = self.assetsBehavior.value
            results.enumerateObjects { (asset, _, _) in
                let key = "thumbnail-\(asset.localIdentifier)"
                if let cachedImage = ImageCache.shared.image(forKey: key) {
                    let model = AssetModel(type: asset.mediaType, asset: asset, issSelected: false, thumbnail: cachedImage, duration: asset.duration)
                    newAsset.append(model)
                } else {
                    self.getThumbnailImage(for: asset) { image in
                        guard let image = image else {
                            return
                        }
                        let model = AssetModel(type: asset.mediaType, asset: asset, issSelected: false, thumbnail: image, duration: asset.duration)
                        newAsset.append(model)
                        if newAsset.count % 20 == 0 {
                            DispatchQueue.main.async {
                               self.assetsBehavior.accept(newAsset)
                           }
                        }
                        ImageCache.shared.setImage(image, forKey: key)
                    }
                }
            }
            DispatchQueue.main.async {
                self.assetsBehavior.accept(newAsset)
            }
        }
    }

    func getThumbnailImage(for asset: PHAsset, completion: @escaping (UIImage?) -> Void) {
        let imageManager = PHImageManager.default()
        let thumbnailOptions = PHImageRequestOptions()
        thumbnailOptions.deliveryMode = .opportunistic
        thumbnailOptions.resizeMode = .exact
        thumbnailOptions.isNetworkAccessAllowed = false
        thumbnailOptions.isSynchronous = true
        imageManager.requestImage(for: asset, targetSize: self.imageCellSize, contentMode: .aspectFill, options: thumbnailOptions) { (image, info) in
            guard let image = image else {
                completion(nil)
                return
            }
            completion(image)
        }
    }
    
    func getImageFromCache(forKey key: String) -> UIImage? {
        let fileManager = FileManager.default
        let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!

        let url = cacheDirectory.appendingPathComponent(key)
        guard fileManager.fileExists(atPath: url.path) else {
            return nil
        }
        return UIImage(contentsOfFile: url.path)
    }

    func saveImageToCache(_ image: UIImage, forKey key: String) {
        let fileManager = FileManager.default
        let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let url = cacheDirectory.appendingPathComponent(key)
        let data = image.jpegData(compressionQuality: 0.8)
        try? data?.write(to: url)
    }
    
    func didSelectItem(index: Int) {
        let asset = self.assetsBehavior.value[index]
        asset.isSelected = !asset.isSelected
        var newArray = assetsBehavior.value
        newArray[index] = asset
        DispatchQueue.main.async {
            self.assetsBehavior.accept(newArray)
        }
    }
    
    func getPhotosSelected() -> [AssetModel] {
        let assets = self.assetsBehavior.value
        var result: [AssetModel] = []
        for asset in assets {
            if asset.isSelected {
                result.append(asset)
            }
        }
        return result
    }
}


class ImageCache {
    static let shared = ImageCache()
    private let cache = NSCache<NSString, UIImage>()
    
    func setImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
    
    func image(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
}
