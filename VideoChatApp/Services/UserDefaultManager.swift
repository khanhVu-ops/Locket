//
//  UserDefaultManager.swift
//  ChatApp
//
//  Created by Vu Khanh on 09/03/2023.
//

import Foundation
import UIKit

class UserDefaultManager {
    static let shared = UserDefaultManager()
    let userDefault = UserDefaults.standard
    let keyIdActive = "idActive"
    let keyNotificationToken = "tokenNotification"
    let keyUsername = "username"
    
    func setID(id: String?) {
        userDefault.setValue(id, forKey: self.keyIdActive)
    }
    
    func getID()-> String? {
        return userDefault.string(forKey: self.keyIdActive)
    }
    
    func setNotificationToken(token: String) {
        userDefault.setValue(token, forKey: self.keyNotificationToken)
    }
    
    func getNotificationToken() -> String {
        return userDefault.string(forKey: self.keyNotificationToken) ?? ""
    }
    
    func setUsername(username: String) {
        userDefault.setValue(username, forKey: self.keyUsername)
    }
    
    func getUsername() -> String {
        return userDefault.string(forKey: self.keyUsername) ?? ""
    }
    
}

