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
    let keyUser = "user"
    
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
    
    func setUser(user: UserModel) {
//        let encoder = JSONEncoder()
//        if let encoded = try? encoder.encode(user) {
//            userDefault.set(encoded, forKey: self.keyUser)
//        }
    }
    
    func getUser() -> UserModel? {
//        guard let savedUser = UserDefaults.standard.object(forKey: self.keyUser) as? Data else {
//            print("Can't get user data from Userdefaults")
//            return nil
//        }
//        let decoder = JSONDecoder()
//        guard let user = try? decoder.decode(UserModel.self, from: savedUser) else {
//            return nil
//        }
        return nil
    }
    
}

