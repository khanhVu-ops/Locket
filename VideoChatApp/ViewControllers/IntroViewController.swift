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
        self.btnGetStarted.addConnerRadius(radius: 15)
        self.btnGetStarted.backgroundColor = Constants.Color.mainColor
    }
    
    @IBAction func btnGetStartedTapped(_ sender: Any) {
//        let registerVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        let registerVC = RegisterViewController()
        self.push(registerVC)
    }
    
}


