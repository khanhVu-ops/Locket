//
//  ChatViewModel.swift
//  ChatApp
//
//  Created by Vu Khanh on 09/03/2023.
//

import Foundation
import RxSwift
import RxCocoa
import FirebaseFirestore
import Photos
import UIKit
class ChatViewModel {
    
    var listMessages = BehaviorRelay<[MessageModel]>(value: [])
    var uid = UserDefaultManager.shared.getID()
    var txtTypeHere = BehaviorRelay<String>(value: "")
    var roomRef: DocumentReference?
    var chatRoom: ChatModel?
    var user2: UserModel?
    var txtUsername = BehaviorRelay<String>(value: "Username")
    var roomURL = BehaviorRelay<String>(value: "")
    var isActive = BehaviorRelay<Bool>(value: false)
    var uid2: String?
    var originalConstraintValue: CGFloat = 0
    var imageSentRelay = PublishRelay<UIImage>()
    func getData() {
        if let uid2 = uid2 {
            self.getInfoUsers2WithUID(uid2: uid2)
            FirebaseManager.shared.getDocumentReferenceWithUserID(userId2: uid2) { [weak self] doc, error in
                guard let doc = doc, error == nil else {
                    return
                }
                self?.roomRef = doc
                self?.getMessages()
                
            }
        }
        
    }
    
    func getInfoUsers2WithUID(uid2: String) {
        FirebaseManager.shared.getUsers { [weak self] users, error in
            guard let users = users, error == nil else {
                return
            }
            for user in users {
                if user.id == uid2 {
                    self?.user2 = user
                    self?.txtUsername.accept(user.username ?? "Username")
                    self?.roomURL.accept(user.avataURL ?? "")
                    self?.isActive.accept(user.isActive ?? false)
                    break
                }
            }
        }
    }
    
    func getMessages() {
        guard let roomRef = roomRef else {
            return
        }
        FirebaseManager.shared.getMessages(docRef: roomRef) {[weak self] messages, error in
            guard let messages = messages, error == nil else {
                print(error!.localizedDescription)
                return
            }
            self?.listMessages.accept(messages)
        }
    }
    
    func didTapSendMessage(type: MessageType, images: [String]? = nil, ratio: Double? = nil, videoURL: String? = nil, thumbVideo: String? = nil, duration: Double? = nil, completion: @escaping(Error?, DocumentReference?)->Void) {
        var content: MessageModel?
        switch type {
        case .text:
            guard self.txtTypeHere.value != "" else {
                completion(nil, nil)
                return
            }
            content = MessageModel(type: .text, message: self.txtTypeHere.value, senderID: self.uid, created: Timestamp(date: Date()))
        case .image:
            guard let images = images, let ratio = ratio else {
                return
            }
            content = MessageModel(type: .image, imageURL: images, ratioImage: ratio, senderID: self.uid, created: Timestamp(date: Date()))
        case .video:
            guard let videoURL = videoURL, let duration = duration else {
                return
            }
            content = MessageModel(type: .video, ratioImage: ratio, thumbVideo: thumbVideo, videoURL: videoURL, duration: duration, senderID: self.uid, created: Timestamp(date: Date()))
            
        }
        
        if let roomRef = roomRef {
            self.addNewMessage(content: content!, roomRef: roomRef) { err, messRef in
                completion(err, messRef)
            }
        } else {
            guard let user2 = self.user2 else {
                completion(nil, nil)
                return
            }
            let roomData = ChatModel(users: [self.uid, user2.id!], roomName: user2.username, roomURL: user2.avataURL)
            self.createNewRoom(newRoom: roomData, content: content!) { roomRef, messRef, error in
                completion(error, messRef)
            }
        }
    }
    
    func createNewRoom(newRoom: ChatModel, content: MessageModel, completion: @escaping(DocumentReference?, DocumentReference?, Error?)->Void) {
        FirebaseManager.shared.creatNewChat(newRoom: newRoom, content: content, completion: {[weak self] roomRef, messRef, error in
            guard let roomRef = roomRef, let messRef = messRef, error == nil else {
                completion(nil ,nil ,error)
                return
            }
            self?.roomRef = roomRef
            self?.getMessages()
            completion(roomRef, messRef,nil)
        })
    }
    
    func addNewMessage(content: MessageModel, roomRef: DocumentReference, completion: @escaping(Error?, DocumentReference?)->Void) {
        FirebaseManager.shared.addNewMessage(content: content, docRef: roomRef) { error, messRef in
            guard error == nil else {
                completion(error, nil)
                return
            }
            completion(nil, messRef)
        }
    }
    
    func sendImage(images: [UIImage], videos: [AssetModel], completion: @escaping(Error?)->Void) {
        let ratio = images[0].size.height/images[0].size.width
        self.didTapSendMessage(type: .image, images: [String](repeating: "Loading", count: images.count), ratio: ratio, videoURL: nil, thumbVideo: nil, duration: nil, completion: { error, messRef in
            guard let messRef = messRef, error == nil else {
                completion(error)
                return
            }
            // send video affter send image
            self.sendVideo(videos: videos, completion: completion)
            var listURL: [String] = []
            for image in images {
                FirebaseManager.shared.uploadImageToStorage(with: image) { url, error in
                    guard let url = url, error == nil else {
                        completion(error)
                        return
                    }
                    listURL.append("\(url)")
                    if listURL.count == images.count {
                        FirebaseManager.shared.updateImageMessage(messRef: messRef, images: listURL, videoURL: "", thumbVideo: "") { err in
                            guard err == nil else {
                                completion(err)
                                return
                            }
                            completion(nil)
                        }
                    }
                }
            }
        })
    }
    
    func sendVideo(videos: [AssetModel], completion: @escaping(Error?)->Void) {
        self.getDataVideo(assets: videos) { results in
            guard let results = results else {
                return
            }
            for (index, result) in results.enumerated() {
                let urlVideo = result.0
                let thumb = result.1
                print("video: ", urlVideo)
                let ratio = thumb.size.height/thumb.size.width
                self.didTapSendMessage(type: .video, images: nil, ratio: ratio, videoURL: "", thumbVideo: "", duration: videos[index].duration) { error, messRef in
                    guard let messRef = messRef, error == nil else {
                        completion(error)
                        return
                    }
                    print("video: ", urlVideo)
                    
                    FirebaseManager.shared.uploadVideo(url: urlVideo, thumb: thumb, messRef: messRef) {error in
                        guard error == nil else {
                            completion(error)
                            return
                        }
                        
                       
                    }
                }
            }
        }
    }
    
    func getDataAndSent(assets: [AssetModel], completion: @escaping(Error?)->Void) {
        var listImages: [AssetModel] = []
        var listVideos: [AssetModel] = []
        for asset in assets {
            if asset.type == .image {
                listImages.append(asset)
            } else {
                listVideos.append(asset)
            }
        }
        // check if images.count == 0, send video else send images
        if listImages.count > 0 {
            self.getDataImage(assets: listImages) { images in
                self.sendImage(images: images, videos: listVideos, completion: completion)
            }
        } else {
            sendVideo(videos: listVideos, completion: completion)
        }
        
    }
    
    func getDataImage(assets: [AssetModel], completion: @escaping([UIImage]) -> Void) {
        var listImages: [UIImage] = []
        for asset in assets {
            // handle image
            let manager = PHImageManager.default()
            let requestOptions = PHImageRequestOptions()
            requestOptions.isNetworkAccessAllowed = true
            
            // Fetch the image data
            manager.requestImageDataAndOrientation(for: asset.asset, options: requestOptions) { imageData, _, _, _ in
                if let imageData = imageData {
                    let img = UIImage(data: imageData)!
                    listImages.append(img)
                    if listImages.count == assets.count {
                        completion(listImages)
                    }
                    // Generate a unique file name for the image
                    
                } else {
                    print("Can't get url")
                    listImages.append(Constants.Image.imageDefault!)
                }
            }
        }
    }
    
    func getDataVideo(assets: [AssetModel], completion: @escaping([(URL, UIImage)]?) -> Void) {
        
        // handle video
        let manager = PHImageManager.default()
        let requestOptions = PHVideoRequestOptions()
        requestOptions.isNetworkAccessAllowed = true
        
        // Fetch the URL of the video
        var res: [(URL, UIImage)] = []
        for asset in assets {
            manager.requestAVAsset(forVideo: asset.asset, options: requestOptions, resultHandler: { (avAsset, audioMix, info) in
                guard let avURLAsset = avAsset as? AVURLAsset else {
                    completion(nil)
                    return
                    // Use the videoURL as needed
                }
                let videoURL = avURLAsset.url
                let requestOptions = PHImageRequestOptions()
                requestOptions.isSynchronous = true
                requestOptions.deliveryMode = .highQualityFormat
                
                PHImageManager.default().requestImage(for: asset.asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: requestOptions) { (image, info) in
                    guard let image = image else {
                        completion(nil)
                        return
                    }
                    res.append((videoURL, image))
                    if res.count == assets.count {
                        completion(res)
                    }
                }
            })
        }
    }
    
    func getListDetailItem() -> [DetailItem] {
        let listMess = self.listMessages.value
        var listDetail = [DetailItem]()
        for mess in listMess {
            if mess.type == .image {
                for url in mess.imageURL ?? [] {
                    let item = DetailItem(type: .image, url: url)
                    listDetail.append(item)
                }
                
            } else if mess.type == .video {
                let item = DetailItem(type: .video, url: mess.videoURL ?? "", isPlaying: true, currentTime: 0.0, duration: mess.duration ?? 0.0)
                listDetail.append(item)
            }
        }
        return listDetail
    }
    
    func calculateHeightMessage(messageWidth: CGFloat, index: Int) -> CGFloat {
        let messageSend = self.listMessages.value[index]
        switch messageSend.type {
        case.image :
            guard let count = messageSend.imageURL?.count else {
                return UITableView.automaticDimension
            }
            if count > 1 {
                var div: CGFloat
                var spaceColumn: CGFloat
                var numberColumn: CGFloat
                if count == 2  || count == 4 {
                    div = CGFloat(count)/2
                    spaceColumn = CGFloat(Constants.spaceImageMessage)
                    numberColumn = 2
                } else {
                    div = ceil(Double(count)/3)
                    spaceColumn = CGFloat(Constants.spaceImageMessage) * 2
                    numberColumn = 3
                }
                let spaceRow = CGFloat(Constants.spaceImageMessage * (Int(div) - 1))
                let widthImage = (messageWidth - spaceColumn)/numberColumn
                return widthImage * div + spaceRow + 45
            } else {
                return  messageWidth * (messageSend.ratioImage ?? 1) + 45
            }
        case .video:
            return messageWidth * (messageSend.ratioImage ?? 1) + 45
        case .text:
            return UITableView.automaticDimension
        case .none:
            return UITableView.automaticDimension
        }
        
    }
    
    func scrollToBottom(tableView: UITableView){
        if self.listMessages.value.count > 0 {
            DispatchQueue.main.async { [weak self] in
                let indexPath = IndexPath(row: (self?.listMessages.value.count)!-1, section: 0)
                tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
            }
        }
        
    }
    
    func reloadData(tableView: UITableView) {
        DispatchQueue.main.async { [weak self] in
//            tableView.reloadData()
            self?.scrollToBottom(tableView: tableView)
        }
    }
    
}
