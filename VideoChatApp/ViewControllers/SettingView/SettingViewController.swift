//
//  SettingViewController.swift
//  ChatApp
//
//  Created by Vu Khanh on 09/03/2023.
//

import UIKit
import RxSwift
import RxCocoa

class SettingViewController: UIViewController {

    let disposeBag = DisposeBag()
    let settingViewModel = SettingViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindingToViewModel()
        // Do any additional setup after loading the view.
    }
    
    func bindingToViewModel() {
        self.settingViewModel.loadingBehavior
            .subscribe(onNext: { [weak self] isLoading in
                isLoading ? self?.showIndicatorWithMessage("Sign out...") : self?.hideIndicatorWithMessage()
            })
            .disposed(by: disposeBag)
    }
    
    @IBAction func btnLogOutTapped(_sender: UIButton) {
        self.settingViewModel.handleLogOut { error in
            guard error == nil else {
                self.showAlert(title: "Error!", message: error!.localizedDescription)
                return
            }
            let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            loginVC.ishiddenBtnBack = true
            self.navigationController?.viewControllers = [loginVC]
            
        }
    }

}
