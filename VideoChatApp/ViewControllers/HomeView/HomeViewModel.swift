//
//  HomeViewModel.swift
//  ChatApp
//
//  Created by Vu Khanh on 10/03/2023.
//

import Foundation
import RxSwift
import RxCocoa
import FirebaseFirestore
class HomeViewModel: BaseViewModel {
    var listChats = BehaviorRelay<[ConverationModel]>(value: [])
    var listUsers = BehaviorRelay<[UserModel]>(value: [])
    var listDocRefChats = BehaviorRelay<[DocumentReference]>(value: [])
    var listSearchs = BehaviorRelay<[UserModel]>(value: [])
    var isEnableSearch = BehaviorRelay<Bool>(value: false)
    var uid = UserDefaultManager.shared.getID()
    private let dataUpdate = PublishSubject<Void>()
    var dataUpdateObsavable: Observable<Void> {
        return dataUpdate.asObservable()
    }
    
    func getListChats() -> Observable<[ConverationModel]> {
        return FirebaseService.shared.getListChats()
            .trackError(errorTracker)
            .asObservable()
    }
    
    func getListUsers() -> Observable<[UserModel]> {
        return FirebaseService.shared.getListUsers()
            .map({ [weak self] users in
                return users.filter({$0.id != self?.uid})
            })
            .trackError(errorTracker)
            .asObservable()
    }
    
    func handleQuery(query: String) {
        let users = listUsers.value
        let listSearch = users.filter({$0.username!.lowercased().hasPrefix(query.lowercased())})
        self.listSearchs.accept(listSearch)
    }
    
    func getUid2FromUsers(users: [String]) -> String? {
        for user in users {
            if user != uid {
                return user
            }
        }
        return nil
    }
    
    func getUserByUID(uid: String) -> Observable<UserModel> {
        return FirebaseService.shared.getUserByUID(uid: uid)
            .trackError(errorTracker)
            .asObservable()
    }
}
