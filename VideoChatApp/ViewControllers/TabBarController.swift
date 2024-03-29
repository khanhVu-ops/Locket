//
//  TabBarController.swift
//  ChatApp
//
//  Created by Vu Khanh on 06/03/2023.
//

import UIKit
import UserNotifications
import RxSwift
import RxCocoa
class TabBarController: UITabBarController {
    
    var customTabBarView = UIView(frame: .zero)
    let disposeBag = DisposeBag()
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.registerNotification()
        configAccount()
        self.setUpView()
        self.setupTabBarUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setupCustomTabBarFrame()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    // MARK: Private methods
    func setUpView() {
        let homeVC = HomeViewController()
        homeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        let settingVC = SettingViewController()
        settingVC.tabBarItem = UITabBarItem(title: "Setting", image: UIImage(systemName: "gearshape"), tag: 1)
        self.viewControllers = [homeVC, settingVC]
    }
    
    func configAccount() {
        guard let id = UserDefaultManager.shared.getID() else {
            return
        }
        FirebaseService.shared.getUserByUID(uid: id)
            .subscribe(onNext: { user in
                var fcm = user.fcmToken ?? []
                let newFcm = UserDefaultManager.shared.getNotificationToken()
                if !fcm.contains(newFcm) {
                    fcm.append(newFcm)
                    AuthFirebaseService.shared.updateFcmToken(fcmToken: fcm)
                }
                AuthFirebaseService.shared.updateUserActive(isActive: true)
                Utilitis.shared.setBadgeIcon(number: user.totalBadge ?? 0)
                print("badge:", user.totalBadge)
                UserDefaultManager.shared.setUsername(username: user.username ?? "")
            })
            .disposed(by: disposeBag)
    }
    
    private func setupCustomTabBarFrame() {
        let height = self.view.safeAreaInsets.bottom + 64
        var tabFrame = self.tabBar.frame
        tabFrame.size.height = height
        tabFrame.origin.y = self.view.frame.size.height - height
        self.tabBar.frame = tabFrame
        self.tabBar.setNeedsLayout()
        self.tabBar.layoutIfNeeded()
        customTabBarView.frame = tabBar.frame
    }
    
    private func setupTabBarUI() {
        // Setup your colors and corner radius
        self.tabBar.backgroundColor = RCValues.shared.color(forKey: .tabbarColor)
        self.tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        self.tabBar.tintColor = RCValues.shared.color(forKey: .appPrimaryColor)
        self.tabBar.unselectedItemTintColor = UIColor.gray
        self.tabBar.addConnerRadius(radius: 15)
        self.tabBar.addShadow(color: .black, opacity: 0.3, radius: 2, offset: CGSize(width: 0, height: 0))
    }
    
    private func registerNotification() {
        let options: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { (granted, error) in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else if granted {
                print("Remote notifications authorized")
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
}
