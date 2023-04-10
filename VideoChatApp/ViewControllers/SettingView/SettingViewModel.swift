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
}
