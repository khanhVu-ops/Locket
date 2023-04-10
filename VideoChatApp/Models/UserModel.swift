//
//  UserModel.swift
//  ChatApp
//
//  Created by Vu Khanh on 09/03/2023.
//

import Foundation

import Foundation

class UserModel {
    var id: String?
    var username: String?
    var password: String?
    var avataURL: String?
    var isActive: Bool?
    
    convenience init(id: String, username: String, password: String, avataURL: String, isActive: Bool) {
        self.init()
        self.id = id
        self.username = username
        self.password = password
        self.isActive = isActive
        self.avataURL = avataURL
    }
    
    convenience init(json: [String : Any]) {
        self.init()
        for (key, value) in json {
            if key == "id", let wrapValue = value as? String {
                let jsonValue = wrapValue
                self.id = jsonValue
            }
            if key == "username", let wrapValue = value as? String {
                let jsonValue = wrapValue
                self.username = jsonValue
            }
            if key == "password", let wrapValue = value as? String {
                let jsonValue = wrapValue
                self.password = jsonValue
            }
            if key == "avataURL", let wrapValue = value as? String {
                let jsonValue = wrapValue
                self.avataURL = jsonValue
            }
            
            if key == "isActive", let wrapValue = value as? Bool {
                let jsonValue = wrapValue
                self.isActive = jsonValue
            }
        }
    }
    
    func convertToDictionary() -> [String: Any] {
        return  [
            "id": self.id ?? "",
            "username": username ?? "",
            "password": password ?? "",
            "avataURL": "",
            "isActive": true
        ] as [String : Any]
    }
}
