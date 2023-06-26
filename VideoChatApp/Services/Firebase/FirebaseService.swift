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
enum FirestorePath: String {
    case users = "users"
    case chats = "chats"
    case conversations = "conversations"
}

enum StoragePath: String {
    case images = "images"
    case files = "files"
    case audios = "audios"
    case videos = "videos"
}

final class FirebaseService: BaseFirebaseService {
    static let shared = FirebaseService()
    let usersClt = "users"
    let chatsClt = "chats"
    let conversationsClt = "conversations"
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
    
    func getUserByUID(uid: String) -> Observable<UserModel> {
        let path = fireStore.collection(usersClt).document(uid)
        return self.rxRequestDocument(path: path)
    }
   
    func getListMessages(conversationID: String) -> Observable<[MessageModel]> {
        let path = fireStore.collection(chatsClt).document(conversationID).collection(conversationsClt).order(by: "created", descending: true).limit(to: 20)
        return self.rxRequestCollection(path: path, isListener: true)
    }
   
    func addConversation(conversation: ConverationModel) -> Observable<String> {
        let path = fireStore.collection(chatsClt).document()
        conversation.conversationID = path.documentID
        let data = conversation.convertToDictionary()
        return self.rxSetData(path: path, data: data)
    }
    
    func addMessage(message: MessageModel, conversationID: String) -> Observable<String> {
        let path = fireStore.collection(chatsClt).document(conversationID).collection(conversationsClt).document()
        message.messageID = path.documentID
        let data = message.convertToDictionary()
        return rxSetData(path: path, data: data)
    }
    
    func updateConversationsWhenAddMessage(conversationID: String, message: MessageModel)  {
        let data = ["lastMessageType": message.type?.rawValue ?? 1,
                    "lastMessage": message.message ?? "",
                    "lastCreated": message.created ?? "",
                    "lastSenderID": message.senderID ?? ""] as [String : Any]
        let path = fireStore.collection(chatsClt).document(conversationID)
        self.updateData(path: path, data: data)
    }
}
