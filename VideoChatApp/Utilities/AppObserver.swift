//
//  AppObserver.swift
//  VideoChatApp
//
//  Created by Khanh Vu on 17/07/5 Reiwa.
//

import Foundation
import UIKit
import RxSwift
class AppObserver {
    static let shared = AppObserver()
    
    private init() {}
    
    private let _messageSentSubject = PublishSubject<String>()
    
    private var _messageSentObservable: Observable<String> {
        return _messageSentSubject.asObserver()
    }
    
    func messageSentSubject() -> PublishSubject<String> {
        return _messageSentSubject
    }
    
    func messageSentObservable() -> Observable<String> {
        return _messageSentObservable
    }
}
