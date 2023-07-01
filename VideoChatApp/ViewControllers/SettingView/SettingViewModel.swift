//
//  SettingViewModel.swift
//  ChatApp
//
//  Created by Vu Khanh on 17/03/2023.
//

import Foundation
import RxSwift
import RxCocoa

class SettingViewModel {
    var loadingBehavior = BehaviorRelay(value: false)
    var userBehavior = PublishRelay<UserModel>()
    var uid = UserDefaultManager.shared.getID()
    func handleLogOut(completion: @escaping(Error?) -> Void) {
        self.loadingBehavior.accept(true)
        FirebaseManager.shared.logOut {[weak self] error in
            self?.loadingBehavior.accept(false)
            guard error == nil else {
                completion(error)
                return
            }
            completion(nil)
        }
    }
    
    func getInfoUser() {
        FirebaseManager.shared.getUsers {[weak self] users, error in
            guard let users = users, error == nil else {
                return
            }
            for user in users {
                if user.id == self?.uid {
                    self?.userBehavior.accept(user)
                    break
                }
            }
        }
    }
    
    func updateAvata(image: UIImage, completion:@escaping (URL?, Error?)->Void) {
        self.loadingBehavior.accept(true)
        FirebaseManager.shared.uploadImageToStorage(with: image) { [weak self] url, error in
            guard let url = url, error == nil else {
                completion(nil, error)
                return
            }
            FirebaseManager.shared.updateAvatar(url: "\(url)") { [weak self] err in
                completion(url, err)
                self?.loadingBehavior.accept(false)
            }
        }
    }
}
