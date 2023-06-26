//
//  Chsa.swift
//  ChatApp
//
//  Created by Vu Khanh on 06/03/2023.
//

import Foundation
import FirebaseFirestore

class ConverationModel: NSObject, JsonInitObject {
    var users: [String]?
    var conversationID: String?
    var conversationName: String?
    var conversationAvata: String?
    var unreadArray: [Int]?
    var lastMessageType: MessageType?
    var lastMessage: String?
    var lastCreated: Timestamp?
    var lastSenderID: String?
    var uid2: String = ""

    convenience init(users: [String]?, conversationID: String? = nil, conversationName: String? = nil, conversationAvata: String? = nil, unreadArray: [Int]? = nil, lastMessageType: MessageType? = .text, lastMessage: String? = nil, lastCreated: Timestamp? = nil, lastSenderID: String? = nil) {
        self.init()
        self.users = users
        self.conversationID = conversationID
        self.conversationName = conversationName
        self.conversationAvata = conversationAvata
        self.unreadArray = unreadArray
        self.lastMessageType = lastMessageType
        self.lastMessage = lastMessage
        self.lastCreated = lastCreated
        self.lastSenderID = lastSenderID
    }
    
    required convenience init(json: [String : Any]) {
        self.init()
        for (key, value) in json {
            if key == "users", let wrapValue = value as? [String] {
                self.users = wrapValue
                for id in wrapValue {
                    if id != UserDefaultManager.shared.getID() {
                        uid2 = id
                    }
                }
            }
            if key == "conversationID", let wrapValue = value as? String {
                self.conversationID = wrapValue
            }
            if key == "conversationName", let wrapValue = value as? String {
                self.conversationName = wrapValue
            }
            if key == "conversationAvata", let wrapValue = value as? String {
                self.conversationAvata = wrapValue
            }
            if key == "unreadArray", let wrapValue = value as? [Int] {
                self.unreadArray = wrapValue
            }
            if key == "lastMessageType", let wrapValue = value as? Int {
                switch wrapValue {
                case 1:
                    self.lastMessageType = .text
                case 2:
                    self.lastMessageType = .image
                case 3:
                    self.lastMessageType = .video
                case 4:
                    self.lastMessageType = .audio
                case 5:
                    self.lastMessageType = .file
                default:
                    break
                }
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
            "conversationName": self.conversationName ?? "",
            "conversationID": self.conversationID ?? "",
            "conversationAvata": self.conversationAvata ?? "",
            "unreadArray": self.unreadArray ?? [],
            "lastMessageType": self.lastMessageType?.rawValue ?? 1,
            "lastMessage": self.lastMessage ?? "",
            "lastCreated": self.lastCreated ?? "",
            "lastSenderID": self.lastSenderID ?? ""
        ] as [String : Any]
    }
}
