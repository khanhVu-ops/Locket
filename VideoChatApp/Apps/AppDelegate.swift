//
//  AppDelegate.swift
//  ChatApp
//
//  Created by Vu Khanh on 06/03/2023.
//

import UIKit
import IQKeyboardManagerSwift
import FirebaseCore
import FirebaseFirestore
import FirebaseMessaging
import AVFoundation
import UserNotifications
import FirebaseAuth
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.window = UIApplication.shared.keyWindow?.window
//        IQKeyboardManager.shared.enable = true
//        IQKeyboardManager.shared.enableAutoToolbar = false
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        }
        catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
        // Override point for customization after application launch.
        return true
    }

    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        print("tẻminate")
        FirebaseManager.shared.updateStatusChating(isChating: false)
        
        guard let id = UserDefaultManager.shared.getID() else {
            return
        }
        FirebaseManager.shared.getUserWithID(id: id) { user, error in
            guard let user = user, error == nil else {
                return
            }
            Utilitis.shared.setBadgeIcon(number: user.totalBadge ?? 0)
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("background")
    }
    
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        updateFirestorePushTokenIfNeeded()
        
    }
    
    func updateFirestorePushTokenIfNeeded() {
        if let token = Messaging.messaging().fcmToken, UserDefaultManager.shared.getID() != "" {
            print("Firebase token: \(token)")
            FirebaseManager.shared.updateFcmToken(fcmToken: token)
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("present")
        let userInfo = notification.request.content.userInfo
        print(userInfo)
        completionHandler([.alert, .badge, .sound])
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
//        print( "respone",response)
        let userInfo = response.notification.request.content.userInfo
        print(userInfo)
        
        guard let dataEncode = userInfo[AnyHashable("gcm.notification.data")] as? String else {
            print("nodata")
            return
        }
        let data = try? JSONDecoder().decode(NotificationMessageModel.self,from: dataEncode.data(using:.utf8)!)
        let uid = data?.uid
        let screenName = data?.screen_name
        print("get window")
        if let scene = UIApplication.shared.connectedScenes.first,
           let windowScene = scene as? UIWindowScene,
           let window = windowScene.windows.first,
           let navigation = window.rootViewController as? UINavigationController,
           navigation.topViewController != ChatViewController() {
            if screenName == "ChatViewController" {
                navigation.popToRootViewController(animated: false)
                if let tabbar = navigation.topViewController as? UITabBarController {
                    tabbar.selectedIndex = 0
                    let chatVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
                    chatVC.viewModel.uid2 = uid ?? ""
                    navigation.pushViewController(chatVC, animated: true)
                }
            }
            // Do something with the window here
        }
    }
}

extension AppDelegate {
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Xử lý thông báo đẩy khi ứng dụng đang chạy")
        // Create a local notification to display the message
        if Auth.auth().canHandleNotification(userInfo) {
                completionHandler(.noData)
                return
        }
            // This notification is not auth related, developer should handle it.
        completionHandler(.newData)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("deviceToken", deviceToken)
        Messaging.messaging().apnsToken = deviceToken
        Auth.auth().setAPNSToken(deviceToken, type: .sandbox)
        updateFirestorePushTokenIfNeeded()
    }
    
    func application(
      _ application: UIApplication,
      didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
      print("Failed to register: \(error)")
    }
}

