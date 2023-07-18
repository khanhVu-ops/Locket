//
//  FirebaseService.swift
//  VideoChatApp
//
//  Created by Khanh Vu on 12/06/5 Reiwa.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import FirebaseFirestore
enum FirestorePath: String {
    case users = "users"
    case chats = "chats"
    case conversations = "conversations"
}

final class FirebaseService: BaseFirebaseService {
    static let shared = FirebaseService()

    let disposeBag = DisposeBag()
        
    func editUsername(username: String) {
        let uid = UserDefaultManager.shared.getID() ?? ""
        let path = fireStore.collection(usersClt).document(uid)
        self.updateData(path: path, data: ["username" : username])
    }
    
    func getListChats() -> Observable<[ConverationModel]> {
        let userID = UserDefaultManager.shared.getID() ?? ""
        let path = fireStore.collection(chatsClt).whereField("users", arrayContains: userID).order(by: "lastCreated", descending: true)
        return self.rxRequestCollection(path: path, isListener: true)
    }
    
    func getListUsers() -> Observable<[UserModel]> {
        let path = fireStore.collection(usersClt)
        return self.rxRequestCollection(path: path, isListener: true)
    }
    
    func getUserByUID(uid: String, isListener: Bool = false) -> Observable<UserModel> {
        let path = fireStore.collection(usersClt).document(uid)
        return self.rxRequestDocument(path: path, isListener: isListener)
    }
   
    func getListMessages(conversationID: String) -> Observable<[MessageModel]> {
        let path = fireStore.collection(chatsClt).document(conversationID).collection(conversationsClt).order(by: "created", descending: true).limit(to: 20)
        return self.rxRequestCollection(path: path, isListener: true)
    }
    
    func fetchMoreMessages(conversationID: String) -> Observable<[MessageModel]> {
        guard let lastMessageSnapshot = self.lastMessageSnapshot else {
            return Observable.of([])
        }
        let path = fireStore.collection(chatsClt)
            .document(conversationID)
            .collection(conversationsClt)
            .order(by: "created", descending: true)
            .start(afterDocument: lastMessageSnapshot)
            .limit(to: 20)
        return self.rxRequestCollection(path: path, isListener: true)
    }
    
    func getConversationID(from uid2: String, completion: @escaping(String?) -> Void) {
        let uid = UserDefaultManager.shared.getID() ?? ""
        let path = fireStore.collection(chatsClt).whereField("users", arrayContains: uid)
        path.getDocuments { snapshot, error in
            guard let snapshot = snapshot, error == nil else {
                completion(nil)
                return
            }
            for document in snapshot.documents {
                let users = document.get("users") as? [String] ?? []
                if users.contains(uid2) {
                    completion(document.documentID)
                    return
                }
            }
            completion(nil)
        }
    }
   
    func addConversation(conversation: ConverationModel) -> Observable<String> {
        let path = fireStore.collection(chatsClt).document()
        conversation.conversationID = path.documentID
        let data = conversation.convertToDictionary()
        return self.rxSetData(path: path, data: data)
    }
    
    func addMessage(type: MessageType, conversationID: String, message: MessageModel, media: [MediaModel]) -> Observable<String> {
        let path = fireStore.collection(chatsClt).document(conversationID).collection(conversationsClt).document()
        message.messageID = path.documentID
        let data = message.convertToDictionary()
        return Observable<String>.create { observable -> Disposable in
            self.updateConversationsWhenAddMessage(conversationID: conversationID, message: message)
            self.setData(path: path, data: data) { [weak self] documentID in
                if type == .text {
                    self?.updateStatus(messageID: documentID, conversationID: conversationID, status: .sent)
                    observable.onNext(documentID)
                } else if type == .image {
                    self?.uploadImageMedia(messageID: documentID, conversationID: conversationID, media: media)
                    observable.onNext(documentID)
                } else {
                    if media.count == 1 {
                        self?.uploadFileMedia(messageID: documentID, conversationID: conversationID, media: media[0])
                        if type == .video {
                            self?.updateThumbVideo(image: media[0].thumbnail, messageID: documentID, conversationID: conversationID)
                        }
                    }
                    observable.onNext(documentID)
                }
                
            } failure: { message in
                observable.onError(AppError(code: .firebase, message: message))
            }
            return Disposables.create()
        }
    }
    
    func updateConversationsWhenAddMessage(conversationID: String, message: MessageModel)  {
        let data = ["lastMessageType": message.type?.rawValue ?? 1,
                    "lastMessage": message.message ?? "",
                    "lastCreated": message.created ?? "",
                    "lastSenderID": message.senderID ?? ""] as [String : Any]
        let path = fireStore.collection(chatsClt).document(conversationID)
        self.updateData(path: path, data: data)
    }
    
    func uploadImageMedia(messageID: String, conversationID: String, media: [MediaModel]) {
        var observables: [Observable<String>] = []
        for medium in media {
            observables.append(self.rxUploadMedia(fileType: medium.type ?? .image, fileURL: medium.filePath)
                                .asObservable())
        }
        Observable.zip(observables)
            .subscribe(onNext: { [weak self] elements in
                self?.updateImageMedia(messageID: messageID, conversationID: conversationID, url: elements)
            }, onCompleted: {
                // Được gọi khi tất cả các Observable đã hoàn thành
                print("All observables completed")
            })
            .disposed(by: disposeBag)
    }
    
    func uploadFileMedia(messageID: String, conversationID: String, media: MediaModel) {
        self.rxUploadMedia(fileType: media.type ?? .image, fileURL: media.filePath)
            .subscribe(onNext: { [weak self] url in
                self?.updateFileMedia(messageID: messageID, conversationID: conversationID, url: url)
            }, onCompleted: {
                // Được gọi khi tất cả các Observable đã hoàn thành
                print("All observables completed")
            })
            .disposed(by: disposeBag)
    }

    func updateFileMedia(messageID: String, conversationID: String, url: String) {
        let path = fireStore.collection(chatsClt).document(conversationID).collection(conversationsClt).document(messageID)
        self.updateData(path: path, data: ["fileURL": url])
        self.updateStatus(messageID: messageID, conversationID: conversationID, status: .sent)
    }
    
    func updateImageMedia(messageID: String, conversationID: String, url: [String]) {
        let path = fireStore.collection(chatsClt).document(conversationID).collection(conversationsClt).document(messageID)
            self.updateData(path: path, data: ["imageURL": url])
        self.updateStatus(messageID: messageID, conversationID: conversationID, status: .sent)
    }
    
    func updateStatus(messageID: String, conversationID: String, status: MessageStatus) {
        let path = fireStore.collection(chatsClt).document(conversationID).collection(conversationsClt).document(messageID)
        self.updateData(path: path, data: ["status": status.rawValue])
        AppObserver.shared.messageSentSubject().onNext(messageID)
    }
    
    func updateThumbVideo(image: UIImage?, messageID: String, conversationID: String) {
        self.uploadImage(image: image) { url in
            let path = self.fireStore.collection(self.chatsClt).document(conversationID).collection(self.conversationsClt).document(messageID)
            path.updateData(["imageURL": [url]])
        } failure: { message in
            print(message)
        }

    }
    
    func uploadAvata(image: UIImage?) -> Observable<String> {
        return Observable.create { observable in
            self.uploadImage(image: image) { url in
                self.updateAvatar(url: url)
                observable.onNext(url)
                observable.onCompleted()
            } failure: { message in
                observable.onError(AppError(code: .firebase, message: message))
            }

            return Disposables.create()
        }
    }
    
    func updateAvatar(url: String) {
        guard let userID = UserDefaultManager.shared.getID() else {
            return
        }
        let ref = fireStore.collection(usersClt).document(userID)
        ref.updateData(["avataURL": url])
    }
    

    
    func updateStatusChating(isChating: Bool) {
        guard let uid = UserDefaultManager.shared.getID() else {
            return
        }
        fireStore.collection(usersClt).document(uid).updateData(["isChating": isChating])
    }
    
    func updateUnreadMessage(conversationID: String, uid: String, clearUnread: Bool) {
        let path = fireStore.collection(chatsClt).document(conversationID)
        path.getDocument { snapshot, error in
            guard let data = snapshot?.data(), error == nil else {
                return
            }
            let chatRoom = ConverationModel(json: data)
            for (index, value) in chatRoom.users!.enumerated() {
                if value == uid {
                    if clearUnread {
                        self.updateTotalBadge(uid: uid, valueUpdate: 0 - chatRoom.unreadArray![index])
                        chatRoom.unreadArray![index] = 0
                    } else {
                        chatRoom.unreadArray![index] += 1
                        self.updateTotalBadge(uid: uid, valueUpdate: 1)
                    }
                    break
                }
            }
            path.updateData(chatRoom.convertToDictionary())
        }
    }
    
    func updateTotalBadge(uid: String, valueUpdate: Int) {
        print(valueUpdate)
        fireStore.collection(usersClt).document(uid).updateData([
            "totalBadge": FieldValue.increment(Int64(valueUpdate))
        ])
    }
}
