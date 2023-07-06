//
//  SettingViewModel.swift
//  ChatApp
//
//  Created by Vu Khanh on 17/03/2023.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

class SettingViewModel: BaseViewModel {
    var uid = UserDefaultManager.shared.getID()
    var user = UserModel()
    func handleLogOut() -> Observable<Void> {
        return AuthFirebaseService.shared.logOut()
            .trackActivity(loading)
            .trackError(errorTracker)
            .asObservable()
    }
    
    func getInfoUser() -> Driver<UserModel> {
        return FirebaseService.shared.getUserByUID(uid: uid!, isListener: true)
            .trackActivity(loading)
            .trackError(errorTracker)
            .asDriverOnErrorJustComplete()
    }
    
    func updateAvata(image: UIImage) -> Observable<String> {
        return FirebaseService.shared.uploadAvata(image: image)
            .trackActivity(loading)
            .trackError(errorTracker)
            .asObservable()
    }
    
    
}
