//
//  TabBarController.swift
//  ChatApp
//
//  Created by Vu Khanh on 06/03/2023.
//

import UIKit

class TabBarController: UITabBarController {
    
   
    
    var customTabBarView = UIView(frame: .zero)
           
       // MARK: View lifecycle
       
       override func viewDidLoad() {
           super.viewDidLoad()
           
           self.setUpView()
           self.setupTabBarUI()
       }
       
       override func viewDidLayoutSubviews() {
           super.viewDidLayoutSubviews()
           self.setupCustomTabBarFrame()
       }
       
       // MARK: Private methods
       
    func setUpView() {
        let homeVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        homeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house"), tag: 0)
        let settingVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SettingViewController") as! SettingViewController
        settingVC.tabBarItem = UITabBarItem(title: "Setting", image: UIImage(systemName: "gearshape"), tag: 1)
      
        self.viewControllers = [homeVC, settingVC]
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
           self.tabBar.backgroundColor = Constants.Color.tabbarColor
           self.tabBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
           self.tabBar.tintColor = .purple
           self.tabBar.unselectedItemTintColor = UIColor.gray
           self.tabBar.addConnerRadius(radius: 15)
           self.tabBar.addShadow(color: .black, opacity: 0.3, radius: 2, offset: CGSize(width: 0, height: 0))
       }
       

}
