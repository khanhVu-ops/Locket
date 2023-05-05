//
//  ViewController.swift
//  ChatApp
//
//  Created by Vu Khanh on 06/03/2023.
//

import UIKit
import Alamofire

class IntroViewController: UIViewController {

    @IBOutlet weak var btnGetStarted: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpView()
    }
    
    func setUpView() {
        self.btnGetStarted.addConnerRadius(radius: 15)
        self.btnGetStarted.backgroundColor = Constants.Color.mainColor
    }
    
    func createNotification() {
        
    }
   
    @IBAction func btnGetStartedTapped(_ sender: Any) {
        let token = UserDefaultManager.shared.getToken()
        createNotification()
        let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController")
        self.navigationController?.pushViewController(loginVC, animated: true)
    }
    
}


