//
//  LoginViewModel.swift
//  ChatApp
//
//  Created by Vu Khanh on 09/03/2023.
//

import Foundation
import RxSwift
import RxCocoa

class LoginViewModel {
    var txtUserName = BehaviorRelay<String>(value: "")
    var txtPassword = BehaviorRelay<String>(value: "")
    var loadingBehavior = BehaviorRelay<Bool>(value: false)
    
    func handleTapLogin(completion: @escaping(ErrorLogin?)->Void) {
        let username = txtUserName.value
        let password = txtPassword.value
        guard username != "" , password != ""  else {
            completion(.notFill)
            return
        }
        self.loadingBehavior.accept(true)
        FirebaseManager.shared.getUsersLogin{ [weak self] users, error in
            guard let users = users, error == nil else {
                completion(.getUserError)
                self?.loadingBehavior.accept(false)
                return
            }
            self?.checkAcountLogin(username: username.trimmingCharacters(in: .whitespacesAndNewlines), password: password.trimmingCharacters(in: .whitespacesAndNewlines), users: users, completion: { error in
                completion(error)
            })
        }
    }
    
    func checkAcountLogin(username: String, password: String, users: [UserModel], completion: @escaping(ErrorLogin?)->Void) {
        for user in users {
            if user.username! == username {
                self.loadingBehavior.accept(false)
//                if user.password! == password {
//                    UserDefaultManager.shared.updateIDWhenLogin(id: user.id!)
//                    FirebaseManager.shared.updateUserActive(isActive: true) { err in
//                        guard err == nil else {
//                            completion(.getUserError)
//                            return
//                        }
//                    }
//                    completion(nil)
//                } else {
//                    completion(.passwordFailed)
//                }
                return
            }
        }

        FirebaseManager.shared.createUser(username: username, password: password) {[weak self] err in
            self?.loadingBehavior.accept(false)
            guard err != nil else {
                completion(nil)
                return
            }
            completion(.createError)
        }
    }
}

enum ErrorLogin: Error, LocalizedError {
    case passwordFailed
    case createError
    case getUserError
    case notFill
    var errorDescription: String? {
        switch self {
        case .passwordFailed:
            return NSLocalizedString("Password failed!!!", comment: "")
        case .createError:
            return NSLocalizedString("Create user Error!!!", comment: "")
        case .notFill:
            return NSLocalizedString("Please fill textField", comment: "")
        default:
            return NSLocalizedString("Get data users Error!!!", comment: "")
        }
    }
}
