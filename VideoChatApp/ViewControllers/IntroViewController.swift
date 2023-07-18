//
//  ViewController.swift
//  ChatApp
//
//  Created by Vu Khanh on 06/03/2023.
//

import UIKit
import Alamofire
class IntroViewController: BaseViewController {

    @IBOutlet weak var btnGetStarted: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpView()
    }
    
    func setUpView() {
        if let uid = UserDefaultManager.shared.getID() {
            FirebaseService.shared.getUserByUID(uid: uid)
                .subscribe(onNext: { user in
                    var fcm = user.fcmToken ?? []
                    let fcmToken = UserDefaultManager.shared.getNotificationToken()
                    print("token", fcmToken)
                    fcm.remove(object: fcmToken)
                    print("fcm: ", fcm.count)
                    AuthFirebaseService.shared.updateFcmToken(fcmToken: fcm)
                    AuthFirebaseService.shared.updateUserActive(isActive: false)
                    Utilitis.shared.setBadgeIcon(number: 0)
                    UserDefaultManager.shared.setID(id: nil)
                })
                .disposed(by: disposeBag)
            
        }
        
        self.btnGetStarted.addConnerRadius(radius: 15)
        self.btnGetStarted.backgroundColor = RCValues.shared.color(forKey: .appPrimaryColor)
    }
    
    @IBAction func btnGetStartedTapped(_ sender: Any) {
//        let registerVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        let registerVC = RegisterViewController()
        self.push(registerVC)
    }
    
}


