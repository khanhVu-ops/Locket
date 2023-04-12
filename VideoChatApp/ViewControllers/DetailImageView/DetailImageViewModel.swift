//
//  DetailImageViewModel.swift
//  VideoChatApp
//
//  Created by Khanh Vu on 04/04/5 Reiwa.
//

import Foundation
import RxSwift
import RxCocoa
import Photos

class DetailItem {
    var type: AssetType
    var url: String
    var isPlaying: Bool
    var currentTime: Double
    var duration: Double
    
    init(type: AssetType, url: String, isPlaying: Bool = true, currentTime: Double = 0.0, duration: Double = 0.0) {
        self.type = type
        self.url = url
        self.isPlaying = isPlaying
        self.currentTime = currentTime
        self.duration = duration
    }
}

class DetailImageViewModel {
    let listImages = BehaviorRelay<[DetailItem]>(value: [])
    let indexItemBehavior = BehaviorRelay<Int>(value: 0)
    let loadingBehavior = BehaviorRelay<Bool>(value: false)
    var currentURL: String?
    
    func scrollToCurrentURL(collectionView: UICollectionView?) {
        guard let currentURL = currentURL, let collectionView = collectionView else {
            return
        }
        let listItem = self.listImages.value
        for item in listItem {
            print("item",item.url)
        }
        guard let index = listItem.firstIndex(where: {$0.url == currentURL}) else {
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            let targetIndexPath = IndexPath(item: index, section: 0) // Specify the target index path
            // Scroll to the item at the target index path
            collectionView.scrollToItem(at: targetIndexPath, at: .right, animated: false)
        })
    }
    
    func saveToLibrary(completion: @escaping(Error?)-> Void) {
        let index = self.indexItemBehavior.value
        let item = self.listImages.value[index]
        self.loadingBehavior.accept(true)
        DispatchQueue.global(qos: .background).async {
            guard let url = URL(string: item.url) else {
                self.loadingBehavior.accept(false)
                return
            }
            do {
                let data = try Data(contentsOf: url)
                switch item.type {
                case.video:
                    let docPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                    let filePath = "\(docPath)/tempFile.mp4"
                    try data.write(to: URL(fileURLWithPath: filePath))
                    PHPhotoLibrary.shared().performChanges({
                        let request = PHAssetCreationRequest.forAsset()
                        request.addResource(with: .video, fileURL: URL(fileURLWithPath: filePath), options: nil)
                        request.creationDate = Date()
                    }) { (result, error) in
                        guard error == nil else {
                            completion(error)
                            self.loadingBehavior.accept(false)
                            return
                        }
                        self.loadingBehavior.accept(false)
                        completion(nil)
                    }
                case .image:
                    guard let image = UIImage(data: data as Data) else {
                        self.loadingBehavior.accept(false)
                        return
                    }
                    PHPhotoLibrary.shared().performChanges({
                        let imageRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
                        imageRequest.creationDate = Date() // Set creation date of the image asset, if needed
                    }, completionHandler: { (success, error) in
                        guard error == nil else {
                            completion(error)
                            self.loadingBehavior.accept(false)
                            return
                        }
                        completion(nil)
                        self.loadingBehavior.accept(false)
                    })
                }
            } catch {
                completion(error)
                self.loadingBehavior.accept(false)
            }
        }
    }
    
}
