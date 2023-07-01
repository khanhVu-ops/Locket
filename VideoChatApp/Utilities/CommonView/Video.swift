//
//  Video.swift
//  VideoChatApp
//
//  Created by Khanh Vu on 28/06/5 Reiwa.
//

import Foundation
import AVFoundation
import Photos
import UIKit

class Video {
    static let shared = Video()
    private let imageCache = NSCache<AnyObject, UIImage>()
    func getThumbnailImageLocal(asset: AVAsset) -> UIImage? {
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        let time = CMTimeMake(value: 1, timescale: 60)
        
        var actualTime = CMTime.zero
        do {
            guard let thumbnailCGImage = try imageGenerator.copyCGImage(at: time, actualTime: &actualTime) as CGImage? else {
                return nil
            }
            
            let thumbnailImage = UIImage(cgImage: thumbnailCGImage)
            return thumbnailImage
        } catch let error {
            print("Error generating thumbnail image: \(error)")
            return nil
        }
    }

    func getThumbnailImage(from videoURL: URL) -> UIImage? {
        let asset = AVURLAsset(url: videoURL)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        
        var thumbnailImage: UIImage?
        
        do {
            let cgImage = try generator.copyCGImage(at: .zero, actualTime: nil)
            thumbnailImage = UIImage(cgImage: cgImage)
        } catch {
            print("Error generating thumbnail image: \(error.localizedDescription)")
        }
        
        return thumbnailImage
    }
    
    func getThumbCached(url: URL) -> UIImage? {
        return imageCache.object(forKey: url as AnyObject)
    }
    func setThumbCached(url: URL,image: UIImage?) {
        guard let img = image else {return}
        imageCache.setObject(img, forKey: url as AnyObject)
    }
    func formatTimeVideo(time: Int) -> String {
        let minutes = Int(time/60)
        let seconds = Int(time%60)
        return String(format:"%02d:%02d", minutes, seconds)
    }
    func downloadVideo(url: URL, fileName: String) {
        DispatchQueue.global(qos: .background).async {
            if let urlData = NSData(contentsOf: url) {
                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                let filePath="\(documentsPath)/\(fileName)"
                DispatchQueue.main.async {
                    urlData.write(toFile: filePath, atomically: true)
                    PHPhotoLibrary.shared().performChanges({
                        let request = PHAssetCreationRequest.forAsset()
                        request.addResource(with: .video, fileURL: URL(fileURLWithPath: filePath), options: nil)
                        request.creationDate = Date()
                    }) { completed, error in
                        guard completed == true else { return }
                        DispatchQueue.main.async {
//                            ToastUtil.show(L10n.saveSuccess)
                        }
                    }
                }
            }
        }
    }
}
