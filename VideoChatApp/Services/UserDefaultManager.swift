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
    
}

