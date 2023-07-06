//
//  PHAsset+Extensions.swift
//  VideoChatApp
//
//  Created by Khanh Vu on 28/06/5 Reiwa.
//

import Foundation
import UIKit
import Photos
extension PHAsset {
    func getImageAspectRatio() -> Double? {
        let aspectRatio: Double = Double(self.pixelWidth) / Double(self.pixelHeight)
        return aspectRatio
    }

    func image(targetSize: CGSize) -> UIImage? {
        var thumbnail: UIImage? = nil
        let imageManager = PHCachingImageManager()
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        if self.playbackStyle == .imageAnimated {
            if #available(iOS 13.0, *) {
                imageManager.requestImageDataAndOrientation(for: self, options: options) { data, _, _, _ in
                    if let data = data, let gifImage = UIImage.sd_image(withGIFData: data) {
                        thumbnail = gifImage
                    }
                }
            }else {
                imageManager.requestImageData(for: self, options: options, resultHandler: { (data, _, _, _) in
                    if let data = data, let gifImage = UIImage.sd_image(withGIFData: data) {
                        thumbnail = gifImage
                    }
                })
            }
        } else {
            imageManager.requestImage(for: self, targetSize: targetSize, contentMode: .aspectFit, options: options, resultHandler: { image, _ in
                thumbnail = image
            })
        }
        return thumbnail
    }
    
    func getThumbnailImage(targetSize: CGSize, completion: @escaping (UIImage) -> Void) {
        let imageManager = PHImageManager.default()
        let thumbnailOptions = PHImageRequestOptions()
        thumbnailOptions.deliveryMode = .opportunistic
        thumbnailOptions.resizeMode = .exact
        thumbnailOptions.isNetworkAccessAllowed = false
        thumbnailOptions.isSynchronous = true
        imageManager.requestImage(for: self, targetSize: targetSize, contentMode: .aspectFill, options: thumbnailOptions) { (image, info) in
            guard let image = image else {
                return
            }
            completion(image)
        }
    }
    
    func image(targetSize: CGSize, completion: @escaping (UIImage) -> Void) {
        let imageManager = PHCachingImageManager()
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        if self.playbackStyle == .imageAnimated {
            if #available(iOS 13.0, *) {
                imageManager.requestImageDataAndOrientation(for: self, options: options) { data, _, _, _ in
                    if let data = data, let gifImage = UIImage.sd_image(withGIFData: data) {
                        completion(gifImage)
                    }
                }
            }else {
                imageManager.requestImageData(for: self, options: options, resultHandler: { (data, _, _, _) in
                    if let data = data, let gifImage = UIImage.sd_image(withGIFData: data) {
                        completion(gifImage)
                    }
                })
            }
        } else {
            imageManager.requestImage(for: self, targetSize: targetSize, contentMode: .aspectFit, options: options, resultHandler: { image, _ in
                guard let image = image else {
                    return
                }
                completion(image)
            })
        }
    }
    func avAsset(completion: @escaping (AVURLAsset?) -> Void){
        var avAsset: AVURLAsset?
        let options: PHVideoRequestOptions = PHVideoRequestOptions()
        options.version = .original
        PHCachingImageManager().requestAVAsset(forVideo: self, options: nil) { (asset, audioMix, args) in
            avAsset = asset as? AVURLAsset
            completion(avAsset)
        }
    }
    func getURLImage(completionHandler: @escaping ((_ responseURL: URL?) -> Void)) {
        let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
        options.canHandleAdjustmentData = { adjustmeta in
            return true
        }
        requestContentEditingInput(with: options) { contentEditingInput, info in
            switch self.mediaType {
            case .image:
                completionHandler(contentEditingInput?.fullSizeImageURL)
            default:
                completionHandler(nil)
            }
        }
    }
    
//    func getFullSizeImageURL(completion: @escaping (URL?) -> Void) {
//        let options = PHImageRequestOptions()
//        options.isNetworkAccessAllowed = true
//        let temporaryDirectoryURL = FileManager.default.temporaryDirectory
//        let fileName = ProcessInfo.processInfo.globallyUniqueString + ".jpeg"
//        let fileURL = temporaryDirectoryURL.appendingPathComponent(fileName)
//        if  FileManager.default.fileExists(atPath: fileURL.path)
//        PHImageManager.default().requestImage(for: self, targetSize: PHImageManagerMaximumSize, contentMode: .default, options: options) { image, info in
//            guard let image = image,
//                  let imageData = image.jpegData(compressionQuality: 0.8) else {
//                completion(nil)
//                return
//            }
//
//            do {
//                try imageData.write(to: fileURL)
//                completion(fileURL)
//            } catch {
//                completion(nil)
//            }
//        }
//    }

}
