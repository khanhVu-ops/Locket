//
//  VerifyCodeViewModel.swift
//  VideoChatApp
//
//  Created by Khanh Vu on 13/06/5 Reiwa.
//

import Foundation
import RxSwift
import RxCocoa

class VerifyCodeViewModel: BaseViewModel {
    let bottomConstant: CGFloat = 25
    var verificationID = ""
    var phoneNumber = ""
    var countDounBehavior = BehaviorRelay<Int>(value: 60)
    
    func verifyPhoneCode(_ code: String) -> Driver<String> {
        return AuthFirebaseService.shared.verifyPhoneCode(verificationID: self.verificationID, code: code)
            .trackActivity(loading)
            .trackError(errorTracker)
            .asDriverOnErrorJustComplete()
    }
    
    func checkAccountExits(_ uid: String) -> Single<UserModel> {
        FirebaseService.shared.checkAccountExists(uid: uid)
//            .trackActivity(loading)
    }
    
    func sendCodeAgain() -> Driver<String> {
        return AuthFirebaseService.shared.sendPhoneCode(phoneNumber: self.phoneNumber.addCountryCode())
            .trackActivity(loading)
            .trackError(errorTracker)
            .asDriverOnErrorJustComplete()
    }
}
