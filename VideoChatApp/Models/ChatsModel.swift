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
    var nickNames: [String]?
    var unreadCount: [Int]?
    var lastMessage: String?
    var lastCreated: Timestamp?
    var lastSenderID: String?
    
    convenience init(users: [String]?, roomName: String? = nil, roomURL: String? = nil, nickNames: [String]? = nil, unreadCount: [Int]? = nil, lastMessage: String? = nil, lastCreated: Timestamp? = nil, lastSenderID: String? = nil) {
        self.init()
        self.users = users
        self.roomName = roomName
        self.roomURL = roomURL
        self.nickNames = nickNames
        self.unreadCount = unreadCount
        self.lastMessage = lastMessage
        self.lastCreated = lastCreated
        self.lastSenderID = lastSenderID
    }
    
    convenience init(json: [String : Any]) {
        self.init()
        
        for (key, value) in json {
            if key == "users", let wrapValue = value as? [String] {
                self.users = wrapValue
            }
            if key == "roomName", let wrapValue = value as? String {
                self.roomName = wrapValue
            }
            if key == "roomURL", let wrapValue = value as? String {
                self.roomURL = wrapValue
            }
            if key == "nickNames", let wrapValue = value as? [String] {
                self.nickNames = wrapValue
            }
            if key == "unreadCount", let wrapValue = value as? [Int] {
                self.unreadCount = wrapValue
            }
            if key == "lastMessage", let wrapValue = value as? String {
                self.lastMessage = wrapValue
            }
            if key == "lastCreated", let wrapValue = value as? Timestamp {
                self.lastCreated = wrapValue
            }
            if key == "lastSenderID", let wrapValue = value as? String {
                self.lastSenderID = wrapValue
            }
        }
    }
    
    func convertToDictionary() -> [String: Any] {
        return [
            "users": self.users ?? [],
            "roomName": self.roomName ?? "",
            "roomURL": self.roomURL ?? "",
            "nickNames": self.nickNames ?? [],
            "unreadCount": self.unreadCount ?? [],
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
