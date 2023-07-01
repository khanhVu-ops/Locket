//
//  ChatViewModel.swift
//  VideoChatApp
//
//  Created by Khanh Vu on 25/06/5 Reiwa.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import FirebaseFirestore

struct MediaUpload {
    let messageID: String
    let url: URL
    let type: MessageType
}
class ChatViewModel: BaseViewModel {
    
    let uploadMediaQueue = DispatchQueue(label: "com.example.uploadMediaQueue", qos: .background, attributes: .concurrent)

    let uid = UserDefaultManager.shared.getID()
    var listMessages = BehaviorRelay<[MessageModel]>(value: [])
    var isFirstLoadData = true
    // textview
    let txtChatPlaceHolder = "Type here ..."
    var currentHeightTv: CGFloat = 0
    var defaultHeightTv: CGFloat = 0
    var maxheightTv: CGFloat = 120
    var isEndEditFromBtnArrow = false
    var txtMessage = ""
    // conversation
    var uid2 = ""
    var user2 = BehaviorRelay<UserModel>(value: UserModel())
    var conversationID = ""
    var newMessageID = PublishRelay<String>()
    var newMessage = MessageModel()
    
    // image, video
    var photosMedia = [MediaModel]()
    var videoMedia = [MediaModel]()
//    var audioMedia = MediaModel()
    // file
    var fileURLPreview: URL?
    
    func getListMessages() -> Observable<[MessageModel]> {
        if conversationID != "" {
            return FirebaseService.shared.getListMessages(conversationID: conversationID)
                .trackError(errorTracker)
                .asObservable()
        } else {
            return Observable.of([])
        }
    }
    
    func sendMessage(type: MessageType, mediaContent: [MediaModel]) -> Observable<String> {
        
        let uid = uid ?? ""
        var content = MessageModel()
        var bodyNotification = ""
        switch type {
        case .text:
            let textMessage = txtMessage.trimmingCharacters(in: .whitespacesAndNewlines)
            content = MessageModel(type: type, message: textMessage, senderID: uid, created: Timestamp(date: Date()))
            bodyNotification = textMessage
            
        default:
            if mediaContent.count > 0 {
                content = MessageModel(type: type, imageURL: type == .image ? [String](repeating: "Loading", count: mediaContent.count) : [], ratioImage: mediaContent[0].ratio, duration: mediaContent[0].duration, senderID: uid, created: Timestamp(date: Date()))
                bodyNotification = "Send you \(photosMedia.count) file."
            }
        }
        self.newMessage = content
        return FirebaseService.shared.addMessage(message: content, conversationID: conversationID)
            .trackError(errorTracker)
            .asObservable()
    }
    
    func addConversation() -> Observable<String> {
        let newConversation = ConverationModel(users: [uid ?? "", uid2], unreadArray: [0, 0])
        return FirebaseService.shared.addConversation(conversation: newConversation)
            .trackError(errorTracker)
            .asObservable()
    }
    
    func handleSendNewMessage(type: MessageType, media: [MediaModel]) {
            if self.conversationID == "" {
                self.addConversation()
                    .subscribe(onNext: { [weak self] conversationID in
                        guard let self = self else {
                            return
                        }
                        self.conversationID = conversationID
                        self.sendMessage(type: type, mediaContent: media)
                            .observe(on: ConcurrentDispatchQueueScheduler(queue: self.uploadMediaQueue))
                            .subscribe(onNext: { [weak self] messageID in
                                self?.updateSentMessage(messageID: messageID, type: type, medias: media)
                            })
                            .disposed(by: self.disposeBag)
                    })
                    .disposed(by: self.disposeBag)
            } else {
                self.sendMessage(type: type, mediaContent: media)
                    .subscribe(onNext: { [weak self] messageID in
                        guard let self = self else {
                            return
                        }
                        self.updateSentMessage(messageID: messageID, type: type, medias: media)
                    })
                    .disposed(by: self.disposeBag)
            }
        
    }
    
    func updateSentMessage(messageID: String, type: MessageType, medias: [MediaModel]) {
        self.newMessageID.accept(messageID)
        FirebaseService.shared.updateConversationsWhenAddMessage(conversationID: self.conversationID, message: self.newMessage)
        if type == .video {
            self.uploadFile(messageID: messageID, type: .image, dataFiles: medias)
        }
        if self.videoMedia.count > 0 {
            for videoMedium in videoMedia {
                self.handleSendNewMessage(type: .video, media: [videoMedium])
            }
            self.videoMedia = []
        }
        if type != .text {
            self.uploadFile(messageID: messageID, type: type, dataFiles: medias)
            if type == .video {
                self.uploadThumnailImage(messageID: messageID, videoMedia: medias[0])
            }
        }
    }
    
    func uploadThumnailImage(messageID: String, videoMedia: MediaModel) {
        guard let thumImage = videoMedia.thumbnail else {
            print("nill")
            return
        }
        FirebaseService.shared.uploadThumbnailImage(messageID: messageID, image: thumImage) { [weak self] upload in
            guard let self = self else {
                return
            }
            FirebaseService.shared.updateMediaImage(messageID: upload.messageID, conversationID: self.conversationID, url: ["\(upload.url)"])
        } failure: { message in
            print(message)
        }
    }
    
    func handleSendAsset(medias: [MediaModel]) {
        let imageMedia = medias.filter({$0.type == .image && checkSize(url: $0.filePath, type: .image)})
        let videoMedia = medias.filter({$0.type != .image && checkSize(url: $0.filePath, type: .video)})
        if imageMedia.count > 0 {
            self.handleSendNewMessage(type: .image, media: imageMedia)
            self.videoMedia = videoMedia
        } else if videoMedia.count > 0 {
            for videoMedium in videoMedia {
                self.handleSendNewMessage(type: .video, media: [videoMedium])
            }
            
        }
    }

    func uploadFile(messageID: String, type: MessageType, dataFiles: [MediaModel]) {
        let count = dataFiles.count
        if count == 0 {
            return
        }
        var observables: [Observable<MediaUpload>] = []
        for dataFile in dataFiles {
            observables.append(FirebaseService.shared.uploadMedia(messageID: messageID, media: dataFile)
                .asObservable())
        }
        var urlImages = [String]()
        let mergeObservable = Observable.merge(observables.map{$0})
            .observe(on: ConcurrentDispatchQueueScheduler(queue: uploadMediaQueue))
            .subscribe(onNext: { [weak self] mediaUpload in
                guard let self = self else {
                    return
                }
                if mediaUpload.type == .image {
                    urlImages.append("\(mediaUpload.url)")
                    FirebaseService.shared.updateMediaImage(messageID: messageID, conversationID: self.conversationID, url: self.appendURLImage(imageURL: urlImages, count: count))
                } else {
                    FirebaseService.shared.updateMediaFile(messageID: messageID, conversationID: self.conversationID, url: "\(mediaUpload.url)")
                }
            })
            .disposed(by: self.disposeBag)
                
//        }
    }
    
    func appendURLImage(imageURL: [String], count: Int) -> [String] {
        var listURL = imageURL
        listURL.append(contentsOf: [String](repeating: "Loading", count: count - imageURL.count))
        return listURL
    }
    
    func checkSize(url: URL?,type: MessageType) -> Bool{
        let size = url?.fileSize() ?? 0
        guard size < 10 || type != .image else {
            Toast.show("Choose image < 10 mb")
            return false
        }
        guard size < 10 || type != .audio else {
            Toast.show("Choose audio < 10 mb")
            return false
        }
        guard size < 100 else {
            Toast.show(type == .file ? "Choose file < 100 mb" : "Choose video < 100 mb")
            return false
        }
        return true
    }
    
//    func calculateHeightMessage(messageWidth: CGFloat, index: Int) -> CGFloat {
//
//        let message = self.listMessages.value[index]
//        switch message.type {
//        case.image :
//            guard let count = message.imageURL?.count else {
//                return UITableView.automaticDimension
//            }
//            if count > 1 {
//                var div: CGFloat
//                var spaceColumn: CGFloat
//                var numberColumn: CGFloat
//                if count == 2  || count == 4 {
//                    div = CGFloat(count)/2
//                    spaceColumn = CGFloat(2)
//                    numberColumn = 2
//                } else {
//                    div = ceil(Double(count)/3)
//                    spaceColumn = CGFloat(2) * 2
//                    numberColumn = 3
//                }
//                let spaceRow = CGFloat(2 * (Int(div) - 1))
//                let widthImage = (messageWidth - spaceColumn)/numberColumn
//                return widthImage * div + spaceRow + 45
//            } else {
//                return  messageWidth * (message.ratioImage ?? 1) + 45
//            }
//        case .video:
//            print("rtio:", message.ratioImage)
//            return messageWidth * (message.ratioImage ?? 1) + 45
//
//        default:
////            return 100
//            return UITableView.automaticDimension
//        }
//    }
    
    func getListDetailItem() -> [DetailItem] {
        var listDetail = [DetailItem]()
        for mess in self.listMessages.value.reversed() {
            if mess.type == .image {
                for url in mess.imageURL ?? [] {
                    let item = DetailItem(type: .image, url: url)
                    listDetail.append(item)
                }
                
            } else if mess.type == .video {
                let item = DetailItem(type: .video, url: mess.fileURL ?? "", isPlaying: true, currentTime: 0.0, duration: mess.duration ?? 0.0)
                listDetail.append(item)
            }
        }
        return listDetail
    }
}
