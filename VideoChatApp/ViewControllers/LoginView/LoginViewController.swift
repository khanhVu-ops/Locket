//
//  LoginViewController.swift
//  ChatApp
//
//  Created by Vu Khanh on 06/03/2023.
//

import UIKit
import RxSwift
import RxCocoa
class LoginViewController: UIViewController {

    @IBOutlet weak var btnEye: UIButton!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var tfUsername: UITextField!
    @IBOutlet weak var vPassword: UIView!
    @IBOutlet weak var vUsername: UIView!
    @IBOutlet weak var btnBack: UIButton!
    
    var eyeType = EyeType.hide
    let disposeBag = DisposeBag()
    let loginViewModel = LoginViewModel()
    var ishiddenBtnBack = false
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
        bindingToViewModel()
    }
    
    func setUpView() {
        self.btnBack.isHidden = self.ishiddenBtnBack
        self.btnBack.addConnerRadius(radius: self.btnBack.frame.width/2)
        self.btnBack.addBorder(borderWidth: 1, borderColor: .black)
        
        self.btnLogin.addConnerRadius(radius: 15)
        self.btnLogin.backgroundColor = Constants.Color.mainColor
        
        self.btnEye.setBackgroundImage(UIImage(systemName: "eye.slash"), for: .normal)
        
        self.vUsername.backgroundColor = .white
        self.vUsername.addBorder(borderWidth: 1, borderColor: .black)
        self.vUsername.addConnerRadius(radius: 20)
        
        self.vPassword.backgroundColor = .white
        self.vPassword.addBorder(borderWidth: 1, borderColor: .black)
        self.vPassword.addConnerRadius(radius: 20)
        
        self.tfUsername.returnKeyType = .continue
        self.tfPassword.returnKeyType = .continue
        self.tfPassword.isSecureTextEntry = true
        self.tfPassword.delegate = self
        self.tfUsername.delegate = self
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }
    
    func bindingToViewModel() {
        self.tfUsername.rx
            .text
            .orEmpty
            .bind(to: self.loginViewModel.txtUserName)
            .disposed(by: disposeBag)
        
        self.tfPassword.rx
            .text
            .orEmpty
            .bind(to: self.loginViewModel.txtPassword)
            .disposed(by: disposeBag)
        
        self.loginViewModel.loadingBehavior
            .subscribe(onNext: { isLoading in
                isLoading ? self.showIndicatorWithMessage("Signing in...") : self.hideIndicatorWithMessage()
            })
            .disposed(by: disposeBag)
    }
    
    @objc func hideKeyboard() {
        self.view.endEditing(true)
    }
    @IBAction func btnBackTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnLoginTapped(_ sender: Any) {
        self.loginViewModel.handleTapLogin { [weak self] error in
            guard error == nil else {
                self?.showAlert(title: "Error!",message: error?.localizedDescription ?? "ERROR")
                return
            }
            let tabbar = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarController")
            self?.navigationController?.viewControllers = [tabbar]
        }
    }
    
    @IBAction func btnEyeTapped(_ sender: Any) {
        switch eyeType {
        case .hide:
            self.eyeType = .show
            self.btnEye.setBackgroundImage(UIImage(systemName: "eye"), for: .normal)
            self.tfPassword.isSecureTextEntry = false
        case .show:
            self.eyeType = .hide
            self.btnEye.setBackgroundImage(UIImage(systemName: "eye.slash"), for: .normal)
            self.tfPassword.isSecureTextEntry = true
        }
    }
}
extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case tfUsername:
            textField.resignFirstResponder()
            self.tfPassword.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return true
    }
}

enum EyeType{
    case hide
    case show
}
