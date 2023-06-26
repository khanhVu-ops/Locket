//
//  AuthFirebaseService.swift
//  VideoChatApp
//
//  Created by Khanh Vu on 12/06/5 Reiwa.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import FirebaseAuth
final class AuthFirebaseService: BaseFirebaseService {
    static let shared = AuthFirebaseService()
    
    func sendPhoneCode(phoneNumber: String) -> Single<String> {
        Single.create { single in
            Auth.auth().languageCode = "vi"
            print("phone", phoneNumber)
            DispatchQueue.main.async {
                PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID,  error in
                    guard let verificationID = verificationID, error == nil else {
                        print("error", error!.localizedDescription)
                        single(.failure(AppError(code: .firebase, message: error!.localizedDescription)))
                        return
                    }
                    print("code", verificationID)
                    single(.success(verificationID))
                }
            }
            
            return Disposables.create()
        }
    }
    
    func verifyPhoneCode(verificationID: String, code: String) -> Single<String> {
        Single.create { single in
            let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: code.trimSpaceAndNewLine())
            Auth.auth().signIn(with: credential) { result, error in
                guard let result = result, error == nil else {
                    single(.failure(AppError(code: .firebase, message: error!.localizedDescription)))
                    return
                }
                single(.success(result.user.uid))
            }
            return Disposables.create()
        }
    }
    
    func checkAccountExists(uid: String) -> Single<UserModel> {
        let path = fireStore.document("users/\(uid)")
        return Single.create { single in
            self.requestDocument(path: path) { data in
                single(.success(data))
            } failure: { message in
                single(.failure(AppError(code: .firebase, message: message)))
            }
            return Disposables.create()
        }
    }
    
    func registerUser(uid: String, phoneNumber: String, username: String) -> Observable<String> {
        let path = fireStore.document("users/\(uid)")
        let newUser = UserModel(id: uid, phoneNumber: phoneNumber, username: username, avataURL: "", isActive: true, fcmToken: []).convertToDictionary()
        UserDefaultManager.shared.setID(id: uid)
        return self.rxSetData(path: path, data: newUser)
    }
}
