//
//  SceneDelegate.swift
//  ChatApp
//
//  Created by Vu Khanh on 06/03/2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
  
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        let st = UIStoryboard(name: "Main", bundle: nil)
        var rootVC = UIViewController()
        if UserDefaultManager.shared.getID() != "" {
            FirebaseManager.shared.updateUserActive(isActive: true) { error in
                guard error == nil else {
                    print(error!.localizedDescription)
                    return
                }
                DispatchQueue.main.async {
                    rootVC = st.instantiateViewController(withIdentifier: "TabBarController") as! TabBarController
                    let nav = UINavigationController(rootViewController: rootVC)
                    nav.navigationBar.isHidden = true
                    window.rootViewController = nav
                    self.window = window
                    self.window?.makeKeyAndVisible()
                }
            }
        } else {
            rootVC = st.instantiateViewController(withIdentifier: "IntroViewController") as! IntroViewController
            let nav = UINavigationController(rootViewController: rootVC)
            nav.navigationBar.isHidden = true
            window.rootViewController = nav
            self.window = window
            self.window?.makeKeyAndVisible()
        }
    }
}
