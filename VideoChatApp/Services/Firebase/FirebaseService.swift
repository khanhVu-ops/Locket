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
    
    func editUsername(username: String) {
        let uid = UserDefaultManager.shared.getID() ?? ""
        let path = fireStore.document("users/\(uid)")
        self.updateData(path: path, data: ["username" : username])
    }
    
    func getListChats() -> Observable<[ChatModel]> {
        let userID = UserDefaultManager.shared.getID() ?? ""
        let path = fireStore.collection("chats").whereField("users", arrayContains: userID).order(by: "lastCreated", descending: true)
        return self.rxRequestCollection(path: path, isListener: true)
    }
    
    func getListUsers() -> Observable<[UserModel]> {
        let path = fireStore.collection("users")
        return self.rxRequestCollection(path: path, isListener: true)
    }
    
    func getUserByUID(uid: String) -> Observable<UserModel> {
        let path = fireStore.collection("users").document(uid)
        return self.rxRequestDocument(path: path)
    }
   
    func getListMessages(conversationID: String) -> Observable<[MessageModel]> {
        let path = fireStore.collection("chats").document(conversationID).collection("converstions").order(by: "created", descending: true).limit(to: 20)
        return self.rxRequestCollection(path: path, isListener: true)
    }
   
    func addNewConversation() -> Observable[ChatModel]
}
