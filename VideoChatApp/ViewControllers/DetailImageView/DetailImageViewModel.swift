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

class DetailImageViewModel: BaseViewModel {
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
    

    func saveToPhotos(with url: String, type: AssetType) -> Observable<Void> {
        return Observable.create { observable in
            DispatchQueue.global(qos: .background).async {
                if let url = URL(string: url) {
                    do {
                        let data = try Data(contentsOf: url)
                        switch type {
                        case.video:
                            let docPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                            let filePath = "\(docPath)/tempFile.mp4"
                            let fileURL = URL(fileURLWithPath: filePath)
                            try data.write(to: fileURL)
                            PHPhotoLibrary.shared().performChanges({
                                let request = PHAssetCreationRequest.forAsset()
                                request.addResource(with: .video, fileURL: fileURL, options: nil)
                                request.creationDate = Date()
                            }) { (result, error) in
                                if error != nil  {
                                    observable.onError(AppError(code: .app, message: error!.localizedDescription))
                                }
                                observable.onNext(())
                                Utilitis.shared.deleteFile(at: fileURL)
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
                                if error != nil  {
                                    observable.onError(AppError(code: .app, message: error!.localizedDescription))
                                }
                                observable.onNext(())
                            })
                        }
                    } catch (let error) {
                        observable.onError(AppError(code: .app, message: error.localizedDescription))

                    }
                } else {
                    observable.onError(AppError(code: .app, message: "URL invalid!"))
                }
            }
            return Disposables.create()
        }
    }
    
    func exportVideoURL(player: AVPlayer, completion: @escaping((URL?) -> Void)) {
        let exportURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("exported_video.mp4")

        guard let asset = player.currentItem?.asset as? AVURLAsset else {
            // Handle invalid asset
            return
        }
        player.rate = 2

        let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)
        exportSession?.outputURL = exportURL
        exportSession?.outputFileType = .mp4
        exportSession?.timeRange = CMTimeRange(start: .zero, duration: asset.duration)

        exportSession?.exportAsynchronously(completionHandler: {
            switch exportSession?.status {
            case .completed:
                print("Export Completed: \(exportURL)")
                // Handle successful export
            case .failed, .cancelled:
                print("Export Failed: \(exportSession?.error?.localizedDescription ?? "")")
                // Handle export failure
            default:
                break
            }
        })
    }
    
    func saveVideoWithURL(urlString: String) {
        guard let videoURL = URL(string: urlString) else {
            return
        } // Replace with the actual URL of the selected video
        let asset = AVAsset(url: videoURL)

        let composition = AVMutableComposition()
        let compositionVideoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)

        if let videoTrack = asset.tracks(withMediaType: .video).first {
            try? compositionVideoTrack?.insertTimeRange(CMTimeRange(start: .zero, duration: asset.duration), of: videoTrack, at: .zero)
        }

        let playerItem = AVPlayerItem(asset: composition)
        let player = AVPlayer(playerItem: playerItem)

        // Change playback rate
        player.rate = 2 // Replace with your desired playback rate (e.g., 0.5 for half speed)
        let exportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)

        let outputPath = NSTemporaryDirectory().appending("modifiedVideo.mp4") // Modify the file name as needed
        exportSession?.outputURL = URL(fileURLWithPath: outputPath)
        exportSession?.outputFileType = .mp4

        exportSession?.exportAsynchronously {
            if exportSession?.status == .completed {
                print("OK")
                self.saveToPhotos(with: outputPath, type: .video)
                // Video export completed
                // You can now save the exported video to the Photos library or perform any other required actions
            } else if exportSession?.status == .failed {
                // Handle export failure
                print("faile")
                print()
            }
        }

    }
    
//    func saveToLibrary(completion: @escaping(Error?)-> Void) {
//
//        self.loadingBehavior.accept(true)
//        DispatchQueue.global(qos: .background).async {
//            guard let url = URL(string: item.url) else {
//                self.loadingBehavior.accept(false)
//                return
//            }
//            do {
//                let data = try Data(contentsOf: url)
//                switch item.type {
//                case.video:
//                    let docPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
//                    let filePath = "\(docPath)/tempFile.mp4"
//                    try data.write(to: URL(fileURLWithPath: filePath))
//                    PHPhotoLibrary.shared().performChanges({
//                        let request = PHAssetCreationRequest.forAsset()
//                        request.addResource(with: .video, fileURL: URL(fileURLWithPath: filePath), options: nil)
//                        request.creationDate = Date()
//                    }) { (result, error) in
//                        guard error == nil else {
//                            completion(error)
//                            self.loadingBehavior.accept(false)
//                            return
//                        }
//                        self.loadingBehavior.accept(false)
//                        completion(nil)
//                    }
//                case .image:
//                    guard let image = UIImage(data: data as Data) else {
//                        self.loadingBehavior.accept(false)
//                        return
//                    }
//                    PHPhotoLibrary.shared().performChanges({
//                        let imageRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
//                        imageRequest.creationDate = Date() // Set creation date of the image asset, if needed
//                    }, completionHandler: { (success, error) in
//                        guard error == nil else {
//                            completion(error)
//                            self.loadingBehavior.accept(false)
//                            return
//                        }
//                        completion(nil)
//                        self.loadingBehavior.accept(false)
//                    })
//                }
//            } catch {
//                completion(error)
//                self.loadingBehavior.accept(false)
//            }
//        }
//    }
}
