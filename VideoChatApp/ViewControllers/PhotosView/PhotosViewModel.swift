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

enum AssetType: Int {
    case video = 2
    case image = 1
}

class PhotosViewModel {
//    var assetsFetchResults: PHFetchResult<PHAsset>!
    var mediaSelect:[MediaModel] = [] {
        didSet {
            updateNewMedia()
        }
    }
    var mediaSelectObservable = BehaviorSubject<[MediaModel]>(value: [])
    var numVideo = 0
    var numImage = 0
    var imageManager: PHCachingImageManager!
    var assetsBehavior = BehaviorRelay<[MediaModel]>(value: [])
    let fetchAssetQueue = DispatchQueue.init(label: "fetchAssetQueue", attributes: .concurrent)
    func fetchAssets() {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchAssetQueue.async {
            let results = PHAsset.fetchAssets(with: options)
            print(results.count)
            var assets = [MediaModel]()
            results.enumerateObjects { (asset, _, _) in
                let media = MediaModel(asset: asset)
                assets.appendUnduplicate(object: media)
            }
            DispatchQueue.main.async {
                self.assetsBehavior.accept(assets)
            }
        }
    }
    
    func updateNewMedia() {
        let numVideo = mediaSelect.filter({ meida in
            meida.type == .video
        }).count
        print("count: ", mediaSelect.count)
        self.numVideo = numVideo
        self.numImage = self.mediaSelect.count - numVideo
        self.mediaSelectObservable.onNext(self.mediaSelect)
    }
    
    func validate(type: MessageType, isSelect: Bool) -> Bool{
        if !isSelect {return true}
        if type == .video && numVideo >= 5 {
            Toast.show("Max 5 video")
            return false
        } else if type == .image && numImage >= 10 {
            Toast.show("Max 10 photo")
            return false
        }
        return true
    }
    
    
//    func getThumbnailImage(for asset: PHAsset, completion: @escaping (UIImage?) -> Void) {
//        let imageManager = PHImageManager.default()
//        let thumbnailOptions = PHImageRequestOptions()
//        thumbnailOptions.deliveryMode = .opportunistic
//        thumbnailOptions.resizeMode = .exact
//        thumbnailOptions.isNetworkAccessAllowed = false
//        thumbnailOptions.isSynchronous = true
//        imageManager.requestImage(for: asset, targetSize: self.imageCellSize, contentMode: .aspectFill, options: thumbnailOptions) { (image, info) in
//            guard let image = image else {
//                completion(nil)
//                return
//            }
//            completion(image)
//        }
//    }
    
//    func getImageFromCache(forKey key: String) -> UIImage? {
//        let fileManager = FileManager.default
//        let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
//
//        let url = cacheDirectory.appendingPathComponent(key)
//        guard fileManager.fileExists(atPath: url.path) else {
//            return nil
//        }
//        return UIImage(contentsOfFile: url.path)
//    }
//
//    func saveImageToCache(_ image: UIImage, forKey key: String) {
//        let fileManager = FileManager.default
//        let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
//        let url = cacheDirectory.appendingPathComponent(key)
//        let data = image.jpegData(compressionQuality: 0.8)
//        try? data?.write(to: url)
//    }
//
    func didSelectItem(index: Int) {
//        let asset = self.assetsBehavior.value[index]
//        asset.isSelected = !asset.isSelected
//        var newArray = assetsBehavior.value
//        newArray[index] = asset
//        DispatchQueue.main.async {
//            self.assetsBehavior.accept(newArray)
//        }
    }
    
//    func getPhotosSelected() -> [AssetModel] {
//        let assets = self.assetsBehavior.value
//        var result: [AssetModel] = []
//        for asset in assets {
//            if asset.isSelected {
//                result.append(asset)
//            }
//        }
//        return result
//    }
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
