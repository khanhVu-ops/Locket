//
//  RegisterViewModel.swift
//  VideoChatApp
//
//  Created by Khanh Vu on 12/06/5 Reiwa.
//

import Foundation
import RxSwift
import RxCocoa
import FirebaseAuth
class RegisterViewModel: BaseViewModel {
    let bottomConstant: CGFloat = 25
    
    func sendPhoneCode(with phoneNumber: String) -> Driver<String>{
        return AuthFirebaseService.shared.sendPhoneCode(phoneNumber: phoneNumber.addCountryCode())
            .trackActivity(loading)
            .trackError(errorTracker)
            .asDriverOnErrorJustComplete()
    }
}
