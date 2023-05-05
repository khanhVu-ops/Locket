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
    func updateIDWhenLogin(id: String) {
        self.setID(id: id)
    }
    
    func updateIDWhenLogOut() {
        self.setID(id: "")
    }
    
    func setID(id: String) {
        userDefault.setValue(id, forKey: self.keyIdActive)
    }
    
    func getID()-> String {
        return userDefault.string(forKey: self.keyIdActive) ?? ""
    }
    
    func setNotificationToken(token: String) {
        userDefault.setValue(token, forKey: self.keyNotificationToken)
    }
    
    func getNotificationToken() -> String{
        return userDefault.string(forKey: self.keyNotificationToken) ?? ""
    }
    
    func setToken(token: Data) {
        userDefault.setValue(token, forKey: "token")
    }
    
    func getToken() -> Data? {
        return userDefault.data(forKey: "token")
    }
    
}

