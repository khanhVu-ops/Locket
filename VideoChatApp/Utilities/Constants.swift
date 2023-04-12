//
//  Constants.swift
//  ChatApp
//
//  Created by Vu Khanh on 06/03/2023.
//

import Foundation
import UIKit

struct Constants {
    static let spaceImageMessage = 2
    struct Color {
        static let mainColor = UIColor(hexString: "#771F98")
        static let tabbarColor = UIColor(hexString: "#F8F8F8")
        static let background = UIColor(hexString: "#242121")
    }
    struct Image {
        static let defaultAvata = UIImage(named: "person_default")
        static let imageDefault = UIImage(named: "image_default")
    }
    struct DBCollectionName {
        static let users = "users"
        static let chats = "chats"
        static let thread = "thread"
    }
}
