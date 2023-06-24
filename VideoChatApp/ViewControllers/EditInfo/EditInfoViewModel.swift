//
//  EditInfoViewModel.swift
//  VideoChatApp
//
//  Created by Khanh Vu on 13/06/5 Reiwa.
//

import Foundation
import RxSwift
import RxCocoa

class EditInfoViewModel: BaseViewModel {
    let bottomConstant: CGFloat = 25
    var phoneNumber = ""
    var uid = ""
    var firstName = BehaviorRelay<String>(value: "")
    var lastName = BehaviorRelay<String>(value: "")

    func registerUser() -> Driver<Bool> {
        let username = (firstName.value.trimSpaceAndNewLine() + " " + lastName.value.trimSpaceAndNewLine()).trimSpaceAndNewLine()
        return FirebaseService.shared.registerUser(uid: uid, phoneNumber: phoneNumber, username: username)
            .trackActivity(loading)
            .trackError(errorTracker)
            .asDriverOnErrorJustComplete()
    }
}
