//
//  ProgressHub+Rx.swift
//  VideoChatApp
//
//  Created by Khanh Vu on 12/06/5 Reiwa.
//

import Foundation
import RxSwift
import RxCocoa
import ProgressHUD

extension ProgressHUD {
    public var rx_progresshud_animating: AnyObserver<Bool> {
        return AnyObserver { event in
            MainScheduler.ensureExecutingOnScheduler()

            switch (event) {
            case .next(let value):
                if value {
                    ProgressHUD.show(interaction: false)
                } else {
                    ProgressHUD.dismiss()
                }
            case .error(let _):
                ProgressHUD.dismiss()
            case .completed:
                ProgressHUD.dismiss()
            }
        }
    }
}
