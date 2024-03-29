//
//  SceneDelegate.swift
//  ChatApp
//
//  Created by Vu Khanh on 06/03/2023.
//

import UIKit
import RxSwift
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
  
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        let st = UIStoryboard(name: "Main", bundle: nil)
        var rootVC = UIViewController()
        if UserDefaultManager.shared.getID() != nil {
            rootVC = TabBarController()
        } else {
            rootVC = st.instantiateViewController(withIdentifier: "IntroViewController") as! IntroViewController
        }
        
        let nav = UINavigationController(rootViewController: rootVC)
        nav.navigationBar.isHidden = true
        window.rootViewController = nav
        self.window = window
        self.window?.makeKeyAndVisible()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {

        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        print("active")
        if let uid = UserDefaultManager.shared.getID() {
            FirebaseService.shared.getUserByUID(uid: uid)
                .subscribe(onNext: { user in
                Utilitis.shared.setBadgeIcon(number: user.totalBadge ?? 0)
                })
                .disposed(by: DisposeBag())
        }
        if let scene = UIApplication.shared.connectedScenes.first,
           let windowScene = scene as? UIWindowScene,
           let window = windowScene.windows.first,
           let navigation = window.rootViewController as? UINavigationController {
                  
            if navigation.topViewController is ChatViewController {
                FirebaseService.shared.updateStatusChating(isChating: true)
            }
        }
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        print("resign")
        FirebaseService.shared.updateStatusChating(isChating: false)
        
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        print("background")
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}
