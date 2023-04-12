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
    @IBOutlet weak var imvAvata: UIImageView!
    @IBOutlet weak var btnChangeAvata: UIButton!
    @IBOutlet weak var btnPlus: UIButton!
    @IBOutlet weak var lbUsername: UILabel!
    let disposeBag = DisposeBag()
    let settingViewModel = SettingViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpView()
        self.settingViewModel.getInfoUser()
        self.bindingToViewModel()
        // Do any additional setup after loading the view.
    }
    
    func setUpView() {
        self.imvAvata.addConnerRadius(radius: self.imvAvata.frame.width/2)
        self.imvAvata.addBorder(borderWidth: 8, borderColor: .black)
        
        self.btnPlus.addConnerRadius(radius: self.btnPlus.frame.width/2)
        self.btnPlus.addBorder(borderWidth: 2, borderColor: .black)
        self.btnChangeAvata.addConnerRadius(radius: self.btnChangeAvata.frame.width/2)
        self.btnChangeAvata.addBorder(borderWidth: 4, borderColor: .systemYellow)
        
    }
    
    func bindingToViewModel() {
        self.settingViewModel.loadingBehavior
            .subscribe(onNext: { [weak self] isLoading in
                isLoading ? self?.showActivityIndicator() : self?.hideActivityIndicator()
            })
            .disposed(by: disposeBag)
        
        self.settingViewModel.userBehavior
            .subscribe(onNext: { [weak self] user in
                if let url = URL(string: user.avataURL ?? "") {
                    self?.imvAvata.sd_setImage(with: url, completed: nil)
                } else {
                    self?.imvAvata.image = Constants.Image.defaultAvata
                }
                self?.lbUsername.text = user.username
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

    @IBAction func btnChangeAvataTapped(_ sender: Any) {
        self.openCamera()
    }
    @IBAction func btnPlusTapped(_ sender: Any) {
        self.openCamera()
    }
    
    func openCamera() {
        let filterVC = FilterViewController()
        filterVC.delegate = self
        filterVC.modalPresentationStyle = .fullScreen
        self.present(filterVC, animated: true, completion: nil)
    }
}

extension SettingViewController: CameraProtocol {
    func didSendImageCaptured(image: UIImage) {
        self.settingViewModel.updateAvata(image: image) { url, error in
            guard let url = url, error == nil else {
                self.showAlert(title: "Error!", message: error!.localizedDescription, completion: nil)
                return
            }
            
            self.imvAvata.sd_setImage(with: url, completed: nil)
        }
    }
    
}



