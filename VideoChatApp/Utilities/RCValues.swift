//
//  File.swift
//  VideoChatApp
//
//  Created by Khanh Vu on 16/07/5 Reiwa.
//

import Foundation
import FirebaseRemoteConfig
import UIKit

enum AppKey: String {
    
    //color
    case appPrimaryColor
    case guestChatColor
    case tapBubleChatColor
    case inputTxtChatColor
    case tabbarColor
    case backgroundColor
    case bgrTextFieldLogin
    // fcm
    case fcmServerKey
    case fcmURL
}

class RCValues {
    static let shared = RCValues()
    
    private init() {
        loadDefaultValues()
        fetchCloudValues()
    }
    
    func loadDefaultValues() {
        let appDefaults: [String: Any?] = [
            AppKey.appPrimaryColor.rawValue : "#FBB03B",
            AppKey.guestChatColor.rawValue : "#F1FFF1",
            AppKey.tapBubleChatColor.rawValue: "#328A0A",
            AppKey.inputTxtChatColor.rawValue: "#DBFFED",
            AppKey.tabbarColor.rawValue: "#F8F8F8",
            AppKey.backgroundColor.rawValue: "#242121",
            AppKey.bgrTextFieldLogin.rawValue: "#403E3E",
        ]
        RemoteConfig.remoteConfig().setDefaults(appDefaults as? [String: NSObject])
      }
    
    func activateDebugMode() {
      let settings = RemoteConfigSettings()
      // WARNING: Don't actually do this in production!
      settings.minimumFetchInterval = 0
      RemoteConfig.remoteConfig().configSettings = settings
    }
    
    func fetchCloudValues() {
      // 1
      activateDebugMode()

      // 2
      RemoteConfig.remoteConfig().fetch { [weak self] _, error in
        if let error = error {
          print("Uh-oh. Got an error fetching remote values \(error)")
          // In a real app, you would probably want to call the loading
          // done callback anyway, and just proceed with the default values.
          // I won't do that here, so we can call attention
          // to the fact that Remote Config isn't loading.
          return
        }

        // 3
        RemoteConfig.remoteConfig().activate { _, _ in
            
          print("Retrieved values from the cloud!")
            let appPrimaryColorString = RemoteConfig.remoteConfig()
                .configValue(forKey: AppKey.backgroundColor.rawValue)
              .stringValue ?? "undefined"
            print("Our app's primary color is \(appPrimaryColorString)")
        }
      }
    }
    
    func color(forKey key: AppKey) -> UIColor {
      let colorAsHexString = RemoteConfig.remoteConfig()[key.rawValue]
        .stringValue ?? "#FFFFFF"
      let convertedColor = UIColor(hexString: colorAsHexString)
      return convertedColor
    }
    
    func bool(forKey key: AppKey) -> Bool {
      RemoteConfig.remoteConfig()[key.rawValue].boolValue
    }

    func string(forKey key: AppKey) -> String {
      RemoteConfig.remoteConfig()[key.rawValue].stringValue ?? ""
    }

    func double(forKey key: AppKey) -> Double {
      RemoteConfig.remoteConfig()[key.rawValue].numberValue.doubleValue
    }
}
