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
import AVFoundation

class ChatViewModel: BaseViewModel {
    
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
    var user = BehaviorRelay<UserModel>(value: UserModel())
    var conversationID = BehaviorRelay<String>(value: "")
    var newMessageID = PublishRelay<String>()
    var newMessage = MessageModel()
    
    // image, video
    var photosMedia = [MediaModel]()
    var videoMedia = [MediaModel]()
    //    var audioMedia = MediaModel()
    // file
    var fileURLPreview: URL?
    var fileSaved: [URL] = []
    
    func getConversationID() {
        if conversationID.value == "" && uid2 != "" {
            FirebaseService.shared.getConversationID(from: uid2) { [weak self] conversation in
                guard let conversation = conversation else {
                    return
                }
                self?.conversationID.accept(conversation)
            }
        }
    }
    
    func getInfoUser() {
        FirebaseService.shared.getUserByUID(uid: uid2, isListener: true)
            .trackError(errorTracker)
            .subscribe(onNext: { [weak self] user in
                self?.user.accept(user)
            })
            .disposed(by: disposeBag)
    }
    
    func getListMessages(conversationID: String) {
        if conversationID != "" {
            FirebaseService.shared.getListMessages(conversationID: conversationID)
                .trackError(errorTracker)
                .subscribe(onNext: { [weak self] messages in
                    guard let self = self, messages.count > 0 else {
                        return
                    }
                    messages[0].isBubble = true
                    self.listMessages.accept(messages)
                })
                .disposed(by: disposeBag)
        }
    }
    
    func loadMoreMessages() -> Observable<[MessageModel]> {
        if conversationID.value != "" {
            return FirebaseService.shared.fetchMoreMessages(conversationID: self.conversationID.value)
                .trackError(errorTracker)
                .asObservable()
                
        }
        return Observable.of([])
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
                content = MessageModel(type: type, imageURL: type == .image || type == .video ? [String](repeating: "loading", count: mediaContent.count) : [], ratioImage: mediaContent[0].ratio, duration: mediaContent[0].duration, fileName: mediaContent[0].fileName, senderID: uid, created: Timestamp(date: Date()))
                bodyNotification = "Send you \(mediaContent.count) file."
            }
        }
        self.newMessage = content
        return FirebaseService.shared.addMessage(type: type, conversationID: conversationID.value, message: content, media: mediaContent)
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
        if self.conversationID.value == "" {
            self.addConversation()
                .subscribe(onNext: { [weak self] newConversationID in
                    guard let self = self else {
                        return
                    }
                    self.conversationID.accept(newConversationID)
                    self.sendMessage(type: type, mediaContent: media)
                        .subscribe(onNext: { [weak self] messageID in
                            self?.conversationID.accept(newConversationID)
                            self?.newMessageID.accept(messageID)
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
                    self.newMessageID.accept(messageID)
                })
                .disposed(by: self.disposeBag)
        }
    }
    
    func checkPermissionAudio(completion: @escaping(Bool) -> Void) {
        let audioSession = AVAudioSession.sharedInstance()
        audioSession.requestRecordPermission { (granted: Bool) -> Void in
            completion(granted)
        }
    }
    
    func handleSendAsset(medias: [MediaModel]) {
        let imageMedia = medias.filter({$0.type == .image})
        let videoMedia = medias.filter({$0.type != .image})
        if imageMedia.count > 0 {
            self.handleSendNewMessage(type: .image, media: imageMedia)
            self.videoMedia = videoMedia
        }
        if videoMedia.count > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                for videoMedium in videoMedia {
                    self?.handleSendNewMessage(type: .video, media: [videoMedium])
                }
            }
        }
    }
    
    func pushNotification() {
        FirebaseService.shared.updateUnreadMessage(conversationID: conversationID.value, uid: uid2, clearUnread: false)
    }
    
    func downloadFile(from url: URL) -> Observable<URL> {
        return Observable.create { observer in
            if let fileName = Utilitis.shared.extractFileName(from: url) {
                let fileManager = FileManager.default
                let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let localFileURL = documentsDirectory.appendingPathComponent(fileName)
                if fileManager.fileExists(atPath: localFileURL.path) {
                    print("file Exist", fileName)
                    observer.onNext(localFileURL)
                    // file exists
                } else {
                    let downloadTask = URLSession.shared.downloadTask(with: url) { (location, response, error) in
                        if let location = location {
                            do {
                                // move item to local file
                                try fileManager.moveItem(at: location, to: localFileURL)
                                self.fileSaved.append(localFileURL)
                                observer.onNext(localFileURL)
                                print("File saved to local path: \(localFileURL.path)")
                            } catch {
                                observer.onError(AppError(code: .app, message: "Save file to local Error!"))
                            }
                        }
                    }
                    downloadTask.resume()
                }
            } else {
                observer.onError(AppError(code: .app, message: "Don't get file name!"))
                
            }
            return Disposables.create()
        }
    }
    
    func updateStatusMessage(messageID: String, status: MessageStatus) {
        FirebaseService.shared.updateStatus(messageID: messageID, conversationID: conversationID.value, status: status)
    }
        
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
    
    func removeFileDownload() {
        for file in self.fileSaved {
            Utilitis.shared.deleteFile(at: file)
        }
    }
}
