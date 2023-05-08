//
//  UserModel.swift
//  ChatApp
//
//  Created by Vu Khanh on 09/03/2023.
//

import Foundation

import Foundation

class UserModel: Codable {
    var id: String?
    var username: String?
    var password: String?
    var avataURL: String?
    var isActive: Bool?
    var fcmToken: String?
    var isChating: Bool?
    
    convenience init(id: String, username: String, password: String, avataURL: String, isActive: Bool, fcmToken: String, isChating: Bool? = nil) {
        self.init()
        self.id = id
        self.username = username
        self.password = password
        self.isActive = isActive
        self.avataURL = avataURL
        self.fcmToken = fcmToken
        self.isChating = isChating
    }
    
    convenience init(json: [String : Any]) {
        self.init()
        for (key, value) in json {
            if key == "id", let wrapValue = value as? String {
                self.id = wrapValue
            }
            if key == "username", let wrapValue = value as? String {
                self.username = wrapValue
            }
            if key == "password", let wrapValue = value as? String {
                self.password = wrapValue
            }
            if key == "avataURL", let wrapValue = value as? String {
                self.avataURL = wrapValue
            }
            
            if key == "fcmToken", let wrapValue = value as? String {
                self.fcmToken = wrapValue
            }
            
            if key == "isActive", let wrapValue = value as? Bool {
                self.isActive = wrapValue
            }
            if key == "isChating", let wrapValue = value as? Bool {
                self.isChating = wrapValue
            }
        }
    }
    
    func convertToDictionary() -> [String: Any] {
        return  [
            "id": self.id ?? "",
            "username": username ?? "",
            "password": password ?? "",
            "avataURL": "",
            "fcmToken": fcmToken ?? "",
            "isActive": true,
            "isChating": false
        ] as [String : Any]
    }
}
