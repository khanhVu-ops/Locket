//
//  UserModel.swift
//  ChatApp
//
//  Created by Vu Khanh on 09/03/2023.
//

import Foundation

import Foundation

class UserModel: NSObject, JsonInitObject {
    var id: String?
    var phoneNumber: String?
    var username: String?
    var avataURL: String?
    var isActive: Bool?
    var fcmToken: [String]?
    var isChating: Bool?
    var totalBadge: Int?
    
    convenience init(id: String, phoneNumber: String?, username: String, avataURL: String, isActive: Bool, fcmToken: [String]? = nil, isChating: Bool? = nil, totalBadge: Int? = 0) {
        self.init()
        self.id = id
        self.username = username
        self.phoneNumber = phoneNumber
        self.isActive = isActive
        self.avataURL = avataURL
        self.fcmToken = fcmToken
        self.isChating = isChating
        self.totalBadge = totalBadge
    }
    
    required convenience init(json: [String : Any]) {
        self.init()
        for (key, value) in json {
            if key == "id", let wrapValue = value as? String {
                self.id = wrapValue
            }
            if key == "username", let wrapValue = value as? String {
                self.username = wrapValue
            }
            if key == "phoneNumber", let wrapValue = value as? String {
                self.phoneNumber = wrapValue
            }
            if key == "avataURL", let wrapValue = value as? String {
                self.avataURL = wrapValue
            }
            
            if key == "fcmToken", let wrapValue = value as? [String] {
                self.fcmToken = wrapValue
            }
            
            if key == "isActive", let wrapValue = value as? Bool {
                self.isActive = wrapValue
            }
            if key == "isChating", let wrapValue = value as? Bool {
                self.isChating = wrapValue
            }
            if key == "totalBadge", let wrapValue = value as? Int {
                self.totalBadge = wrapValue
            }
        }
    }
    
    func convertToDictionary() -> [String: Any] {
        return  [
            "id": self.id ?? "",
            "username": username ?? "",
            "phoneNumber": phoneNumber ?? "",
            "avataURL": "",
            "fcmToken": fcmToken ?? [],
            "isActive": true,
            "isChating": false,
            "totalBadge": totalBadge ?? 0
        ] as [String : Any]
    }
}
