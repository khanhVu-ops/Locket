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
        static let tapBubleColor = UIColor(hexString: "#328A0A")
        static let mainColor = UIColor(hexString: "#47C40F")
        static let tabbarColor = UIColor(hexString: "#F8F8F8")
        static let background = UIColor(hexString: "#242121")
        static let bgrTextField = UIColor(hexString: "#403E3E")
        static let bgrButton = UIColor(hexString: "#f8bb01")
    }
    struct Image {
        static let defaultAvata = UIImage(named: "person_default")!
        static let imageDefault = UIImage(named: "library")!
        static let backButton = UIImage(systemName: "chevron.left")!
        static let ic_flag_vn = UIImage(named: "ic_flag_vn")!
    }
    
    struct L10n {
        static let commonError = "Oops! Something went wrong. Please try again later!"
        static let commonErrorTimeout = "Oops! Request timeout. Please try again later!"
    }
}
