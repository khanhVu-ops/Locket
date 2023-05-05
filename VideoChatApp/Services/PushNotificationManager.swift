//
//  PushNotificationManager.swift
//  VideoChatApp
//
//  Created by Khanh Vu on 24/04/5 Reiwa.
//
//
//import Foundation
//import FirebaseMessaging
//import UIKit
//import UserNotifications
//import FirebaseFirestore
//
//class PushNotificationManager: NSObject {
//    let userID: String
//    init(userID: String) {
//        self.userID = userID
//    }
//    
//    func registerForPushNotifications() {
////        UNUserNotificationCenter.current().delegate = self
//
//        // Request user permission for notifications
//        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
//            if granted {
//                DispatchQueue.main.async {
//                    UIApplication.shared.registerForRemoteNotifications()
//                    self.updateFirestorePushTokenIfNeeded()
//                    
//                }
//            }
//        }
//    }
//    
//    
//
//    
//}




