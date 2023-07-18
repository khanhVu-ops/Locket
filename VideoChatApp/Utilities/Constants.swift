//
//  Constants.swift
//  VideoChatApp
//
//  Created by Khanh Vu on 12/06/5 Reiwa.
//

import Foundation
import UIKit
struct Constants {
    struct Color {

    }
    struct Image {
        static let defaultAvataImage = UIImage(named: "avata_default")!
        static let defaultImage = UIImage(named: "image")!
        static let flagVNIcon = UIImage(named: "ic_flag_vn")!
        static let playCircleIcon = UIImage(named: "ic_play_circle")!
        static let switchCameraSystem = UIImage(systemName: "camera.rotate.fill")!
        static let backButtonSystem = UIImage(systemName: "chevron.left")!
        static let downloadSystem = UIImage(systemName: "arrow.down.to.line.compact")!
        static let cancelSystem = UIImage(systemName: "xmark")!
        static let flashSystem = UIImage(systemName: "bolt.slash.fill")!
    }
    
    struct L10n {
        static let commonErrorText = "Oops! Something went wrong. Please try again later!"
        static let commonErrorTimeoutText = "Oops! Request timeout. Please try again later!"
    }
}
