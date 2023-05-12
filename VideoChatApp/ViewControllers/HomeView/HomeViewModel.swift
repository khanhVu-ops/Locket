//
//  HomeViewModel.swift
//  ChatApp
//
//  Created by Vu Khanh on 10/03/2023.
//

import Foundation
import RxSwift
import RxCocoa
import FirebaseFirestore
class HomeViewModel {
    var listChatRooms = BehaviorRelay<[ChatModel]>(value: [])
    var listUsers = BehaviorRelay<[UserModel]>(value: [])
    var listDocRefChats = BehaviorRelay<[DocumentReference]>(value: [])
    var listSearchUsers = BehaviorRelay<[UserModel]>(value: [])
    var isEnableSearch = BehaviorRelay<Bool>(value: false)
    var uid = UserDefaultManager.shared.getID()

    func updateData() {
        FirebaseManager.shared.getListChats { [weak self] chats, docRef, error in
            guard let chats = chats, let docRef = docRef, error == nil else {
                return
            }
            let rooms = [ChatModel()] + chats
            self?.listChatRooms.accept(rooms)
            FirebaseManager.shared.getUsers {[weak self] users, error in
                guard let users = users, error == nil else {
                    return
                }
                let arrUsers = users.filter({
                    $0.id != self?.uid
                })
                for chat in chats {
                    var uid2 = ""
                    for id in chat.users! {
                        if id != self?.uid {
                            uid2 = id
                            break
                        }
                    }
                    for user in users {
                        if user.id == uid2 {
                            chat.updateNameAndRoomURL(name: user.username, roomURL: user.avataURL)
                            break
                        }
                    }
                }
                let rooms = [ChatModel()] + chats
                self?.listChatRooms.accept(rooms)
                self?.listUsers.accept(arrUsers)
            }
            self?.listDocRefChats.accept(docRef)
        }
    }
    
    func handleQuery(query: String) {
        let users = listUsers.value
        let listSearch = users.filter({$0.username!.lowercased().hasPrefix(query.lowercased())})
        self.listSearchUsers.accept(listSearch)
    }
    
    func getUid2FromUsers(users: [String]) -> String? {
        for user in users {
            if user != uid {
                return user
            }
        }
        return nil
    }
    
    
}
