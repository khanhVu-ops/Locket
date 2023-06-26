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
class ChatViewModel: BaseViewModel {
    
    let uid = UserDefaultManager.shared.getID()
    var listMessages = BehaviorRelay<[MessageModel]>(value: [])
    
    // textview
    let txtChatPlaceHolder = "Type here ..."
    var txtTypeHere = BehaviorRelay<String>(value: "")
    var currentHeightTv: CGFloat = 0
    var defaultHeightTv: CGFloat = 0
    var maxheightTv: CGFloat = 120
    
    // conversation
    var uid2 = ""
    var user2 = BehaviorRelay<UserModel>(value: UserModel())
    var conversationID = ""
    var newMessageID = PublishRelay<String>()
    var newMessage = MessageModel()
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
    
    func sendMessage(type: MessageType, images: [String] = [], ratio: Double = 1.0, videoURL: String = "", thumbVideo: String = "", audioURL: String = "", duration: Double = 0.0, fileName: String = "", fileURL: String = "") -> Observable<String> {
        
        let uid = uid ?? ""
        var content = MessageModel()
        var bodyNotification = ""
        switch type {
        case .text:
            let textMessage = self.txtTypeHere.value.trimmingCharacters(in: .whitespacesAndNewlines)
            content = MessageModel(type: .text, message: textMessage, senderID: uid, created: Timestamp(date: Date()))
            bodyNotification = textMessage
            
        case .image:
            content = MessageModel(type: .image, imageURL: images, ratioImage: ratio, senderID: uid, created: Timestamp(date: Date()))
            bodyNotification = "Send you \(images.count) picture."
        case .video:

            content = MessageModel(type: .video, ratioImage: ratio, thumbVideo: thumbVideo, videoURL: videoURL, duration: duration, senderID: uid, created: Timestamp(date: Date()))
            bodyNotification = "Send you a video."
        case .file:

            content = MessageModel(type: .file, fileName: fileName, senderID: uid, created: Timestamp(date: Date()))
            bodyNotification = "Send you a file."
        case .audio:

            content = MessageModel(type: .audio, audioURL: audioURL, duration: duration, senderID: uid, created: Timestamp(date: Date()))
            bodyNotification = "Send you a audio."
        }
        self.newMessage = content
        return FirebaseService.shared.addMessage(message: content, conversationID: conversationID)
            .trackError(errorTracker)
            .asObservable()
        //            if self.user2.value.isChating == false {
        //                    FirebaseManager.shared.updateUnreadMessage(id: self.uid2, clearUnread: false, roomRef: roomRef)
        //                    APIService.shared.pushNotificationMessage(fcmToken: self.user2?.fcmToken, uid: self.uid, title: self.user!.username, body: bodyNotification, badge: (self.user2?.totalBadge ?? 0) + 1)
        //                }
    }
    
    func addConversation() -> Observable<String> {
        let newConversation = ConverationModel(users: [uid ?? "", uid2], unreadArray: [0, 0])
        return FirebaseService.shared.addConversation(conversation: newConversation)
            .trackError(errorTracker)
            .asObservable()
    }
    
    func handleTapBtnSend(type: MessageType) {
        if conversationID == "" {
            self.addConversation()
                .subscribe(onNext: { [weak self] conversationID in
                    guard let self = self else {
                        return
                    }
                    self.conversationID = conversationID
                    self.sendMessage(type: type)
                        .subscribe(onNext: { [weak self] messageID in
                            guard let strongSelf = self else {
                                return
                            }
                            strongSelf.newMessageID.accept(messageID)
                            FirebaseService.shared.updateConversationsWhenAddMessage(conversationID: strongSelf.conversationID, message: strongSelf.newMessage)
                        })
                        .disposed(by: self.disposeBag)
                })
                .disposed(by: disposeBag)
        } else {
            self.sendMessage(type: type)
                .subscribe(onNext: { [weak self] messageID in
                    guard let self = self else {
                        return
                    }
                    self.newMessageID.accept(messageID)
                    FirebaseService.shared.updateConversationsWhenAddMessage(conversationID: self.conversationID, message: self.newMessage)
                })
                .disposed(by: disposeBag)
        }
    }
    
    func calculateHeightMessage(messageWidth: CGFloat, index: Int) -> CGFloat {

        let message = self.listMessages.value[index]
        switch message.type {
        case.image :
            guard let count = message.imageURL?.count else {
                return UITableView.automaticDimension
            }
            if count > 1 {
                var div: CGFloat
                var spaceColumn: CGFloat
                var numberColumn: CGFloat
                if count == 2  || count == 4 {
                    div = CGFloat(count)/2
                    spaceColumn = CGFloat(2)
                    numberColumn = 2
                } else {
                    div = ceil(Double(count)/3)
                    spaceColumn = CGFloat(2) * 2
                    numberColumn = 3
                }
                let spaceRow = CGFloat(2 * (Int(div) - 1))
                let widthImage = (messageWidth - spaceColumn)/numberColumn
                return widthImage * div + spaceRow + 45
            } else {
                return  messageWidth * (message.ratioImage ?? 1) + 45
            }
        case .video:
            print("rtio:", message.ratioImage)
            return messageWidth * (message.ratioImage ?? 1) + 45
            
        default:
//            return 100
            return UITableView.automaticDimension
        }
    }
}
