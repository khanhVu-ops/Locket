//
//  DetailImageViewModel.swift
//  VideoChatApp
//
//  Created by Khanh Vu on 04/04/5 Reiwa.
//

import Foundation
import RxSwift
import RxCocoa

class DetailItem {
    var type: DetailType
    var url: String
    var isPlaying: Bool
    var currentTime: Double
    var duration: Double
    
    init(type: DetailType, url: String, isPlaying: Bool = true, currentTime: Double = 0.0, duration: Double = 0.0) {
        self.type = type
        self.url = url
        self.isPlaying = isPlaying
        self.currentTime = currentTime
        self.duration = duration
    }
}

enum DetailType {
    case video
    case image
}

class DetailImageViewModel {
    let listImages = BehaviorRelay<[DetailItem]>(value: [
        DetailItem(type: .image, url: "https://firebasestorage.googleapis.com:443/v0/b/chatapp-3a479.appspot.com/o/M87gwHYab0ZuAPBvbaKV%2FM87gwHYab0ZuAPBvbaKV1680231239.001993?alt=media&token=93355787-1fa5-41dd-aa2d-e6a05a2a105a"),
        
        DetailItem(type: .video, url: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4", isPlaying: true, currentTime: 0.0),

        DetailItem(type: .image, url: "https://firebasestorage.googleapis.com:443/v0/b/chatapp-3a479.appspot.com/o/M87gwHYab0ZuAPBvbaKV%2FM87gwHYab0ZuAPBvbaKV1680231239.001993?alt=media&token=93355787-1fa5-41dd-aa2d-e6a05a2a105a"),

        DetailItem(type: .image, url: "https://firebasestorage.googleapis.com:443/v0/b/chatapp-3a479.appspot.com/o/M87gwHYab0ZuAPBvbaKV%2FM87gwHYab0ZuAPBvbaKV1680231239.001993?alt=media&token=93355787-1fa5-41dd-aa2d-e6a05a2a105a"),
        DetailItem(type: .image, url: "https://firebasestorage.googleapis.com:443/v0/b/chatapp-3a479.appspot.com/o/M87gwHYab0ZuAPBvbaKV%2FM87gwHYab0ZuAPBvbaKV1680231239.001993?alt=media&token=93355787-1fa5-41dd-aa2d-e6a05a2a105a"),
        DetailItem(type: .video, url: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4", isPlaying: true, currentTime: 0.0),
        DetailItem(type: .video, url: "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4", isPlaying: true, currentTime: 0.0),
        DetailItem(type: .image, url: "https://firebasestorage.googleapis.com:443/v0/b/chatapp-3a479.appspot.com/o/M87gwHYab0ZuAPBvbaKV%2FM87gwHYab0ZuAPBvbaKV1680231239.001993?alt=media&token=93355787-1fa5-41dd-aa2d-e6a05a2a105a"),
        
        DetailItem(type: .image, url: "https://firebasestorage.googleapis.com:443/v0/b/chatapp-3a479.appspot.com/o/M87gwHYab0ZuAPBvbaKV%2FM87gwHYab0ZuAPBvbaKV1680231239.001993?alt=media&token=93355787-1fa5-41dd-aa2d-e6a05a2a105a"),
        DetailItem(type: .image, url: "https://firebasestorage.googleapis.com:443/v0/b/chatapp-3a479.appspot.com/o/M87gwHYab0ZuAPBvbaKV%2FM87gwHYab0ZuAPBvbaKV1680231239.001993?alt=media&token=93355787-1fa5-41dd-aa2d-e6a05a2a105a"),
        DetailItem(type: .image, url: "https://firebasestorage.googleapis.com:443/v0/b/chatapp-3a479.appspot.com/o/M87gwHYab0ZuAPBvbaKV%2FM87gwHYab0ZuAPBvbaKV1680231239.001993?alt=media&token=93355787-1fa5-41dd-aa2d-e6a05a2a105a"),
    ])
    
    let indexItemBehavior = BehaviorRelay<Int>(value: 0)
    
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
        print(index)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            let targetIndexPath = IndexPath(item: index, section: 0) // Specify the target index path
            // Scroll to the item at the target index path
            collectionView.scrollToItem(at: targetIndexPath, at: .right, animated: false)
        })
        
    }
}
