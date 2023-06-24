//
//  Toast.swift
//  VideoChatApp
//
//  Created by Khanh Vu on 12/06/5 Reiwa.
//

import Foundation
import UIKit
import Toast_Swift
final class Toast {
    
    private init() {}
    
    static var style: ToastStyle = {
        var style = ToastStyle()
        style.cornerRadius = 8
        style.backgroundColor = .black
        style.imageSize = CGSize(width: 19, height: 19)
        style.messageAlignment = .center
        style.titleAlignment = .center
        style.messageColor = .white
        style.messageFont  = UIFont.systemFont(ofSize: 14)
        style.verticalPadding = 14
        style.horizontalPadding = 16
        return style
    }()
    
    static func show(_ message: String?, title: String? = nil, image: UIImage? = nil, duration: TimeInterval = ToastManager.shared.duration) {
        guard !message.isNilOrEmpty || !title.isNilOrEmpty else { return }
        guard let keyWindow = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first else {
            return
        }
        
        ToastManager.shared.style = style
        ToastManager.shared.position = .top
        hideAll()
        let toast = try! keyWindow.toastViewForMessage(message, title: title, image: image, style: style)
        toast.layer.zPosition = 10
        keyWindow.showToast(toast, duration: duration)
    }
    
    static func hide() {
        guard let keyWindow = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first else {
            return
        }
        keyWindow.hideToast()
    }
    
    static func hideAll() {
        guard let keyWindow = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first else {
            return
        }
        keyWindow.hideAllToasts()
    }
}
