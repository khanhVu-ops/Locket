//
//  BaseViewModel.swift
//  VideoChatApp
//
//  Created by Khanh Vu on 12/06/5 Reiwa.
//

import Foundation
import RxSwift
import RxCocoa
import ProgressHUD

class BaseViewModel {
    var errorMsg    = PublishRelay<String>()
    var errorAppCode   = PublishRelay<Int>()
    var disposeBag  = DisposeBag()
    let progress    = ProgressHUD()
    
    let errorTracker: ErrorTracker
    let loading         = ActivityIndicator()
    let headerLoading   = ActivityIndicator()
    let footerLoading   = ActivityIndicator()

    init() {
        errorTracker = ErrorTracker()
        errorTracker.asObservable().subscribe(onNext: { [weak self] (error) in
            self?.handleError(error)
            
        }).disposed(by: disposeBag)
        
        loading.asObservable()
            .bind(to: progress.rx_progresshud_animating)
            .disposed(by: disposeBag)
    }
    func handleError(_ error: Error) {
        if let error = error as? AppError {
            if !error.message.isEmpty {
                errorMsg.accept(error.message)
            } else {
                errorMsg.accept(Constants.L10n.commonErrorText)
            }
            errorAppCode.accept(error.code.rawValue)
        }
        else if let error = error as? RxSwift.RxError {
            switch error {
            case .timeout:
                errorMsg.accept(Constants.L10n.commonErrorTimeoutText)
            default:
                errorMsg.accept(Constants.L10n.commonErrorText)
            }
        }
        else {
            errorMsg.accept(Constants.L10n.commonErrorText)
        }
    }
}
