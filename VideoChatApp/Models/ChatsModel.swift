//
//  Chsa.swift
//  ChatApp
//
//  Created by Vu Khanh on 06/03/2023.
//

import Foundation
import FirebaseFirestore
class ChatModel {
    var users: [String]?
    var roomName: String?
    var roomURL: String?
    var lastMessage: String?
    var lastCreated: Timestamp?
    var lastSenderID: String?
    
    
    convenience init(users: [String]?, roomName: String? = nil, roomURL: String? = nil, lastMessage: String? = nil, lastCreated: Timestamp? = nil, lastSenderID: String? = nil) {
        self.init()
        self.users = users
        self.roomName = roomName
        self.roomURL = roomURL
        self.lastMessage = lastMessage
        self.lastCreated = lastCreated
        self.lastSenderID = lastSenderID
    }
    
    convenience init(json: [String : Any]) {
        self.init()
        
        for (key, value) in json {
            if key == "users", let wrapValue = value as? [String] {
                let jsonValue = wrapValue
                self.users = jsonValue
            }
            if key == "roomName", let wrapValue = value as? String {
                let jsonValue = wrapValue
                self.roomName = jsonValue
            }
            if key == "roomURL", let wrapValue = value as? String {
                let jsonValue = wrapValue
                self.roomURL = jsonValue
            }
            if key == "lastMessage", let wrapValue = value as? String {
                let jsonValue = wrapValue
                self.lastMessage = jsonValue
            }
            if key == "lastCreated", let wrapValue = value as? Timestamp {
                let jsonValue = wrapValue
                self.lastCreated = jsonValue
            }
            if key == "lastSenderID", let wrapValue = value as? String {
                let jsonValue = wrapValue
                self.lastSenderID = jsonValue
            }
        }
    }
    
    func convertToDictionary() -> [String: Any] {
        return [
            "users": self.users ?? [],
            "roomName": self.roomName ?? "",
            "roomURL": self.roomURL ?? "",
            "lastMessage": self.lastMessage ?? "",
            "lastCreated": self.lastCreated ?? "",
            "lastSenderID": self.lastSenderID ?? ""
        ] as [String : Any]
    }
    
    func updateNameAndRoomURL(name: String?, roomURL: String?) {
        self.roomName = name
        self.roomURL = roomURL
    }
    
    
}
