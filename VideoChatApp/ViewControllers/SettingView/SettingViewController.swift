//
//  SettingViewController.swift
//  ChatApp
//
//  Created by Vu Khanh on 09/03/2023.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Photos
class SettingViewController: BaseViewController {
    @IBOutlet weak var imvAvata: UIImageView!
    @IBOutlet weak var btnChangeAvata: UIButton!
    @IBOutlet weak var btnPlus: UIButton!
    @IBOutlet weak var lbUsername: UILabel!
    let settingViewModel = SettingViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.settingViewModel.getInfoUser()
        // Do any additional setup after loading the view.
    }
    
    
    override func setUpUI() {
        self.imvAvata.addConnerRadius(radius: self.imvAvata.frame.width/2)
        self.imvAvata.addBorder(borderWidth: 8, borderColor: .black)
        
        self.btnPlus.addConnerRadius(radius: self.btnPlus.frame.width/2)
        self.btnPlus.addBorder(borderWidth: 2, borderColor: .black)
        self.btnChangeAvata.addConnerRadius(radius: self.btnChangeAvata.frame.width/2)
        self.btnChangeAvata.addBorder(borderWidth: 4, borderColor: .systemYellow)
    }
    
    override func bindViewModel() {
        
        self.settingViewModel.getInfoUser()
            .drive(onNext: { [weak self] user in
                self?.settingViewModel.user = user
                self?.imvAvata.setImage(urlString: user.avataURL ?? "", placeHolder: Constants.Image.defaultAvata)
                self?.lbUsername.text = user.username
            })
            .disposed(by: disposeBag)
    }
    
    @IBAction func btnLogOutTapped(_sender: UIButton) {
        self.settingViewModel.handleLogOut()
            .subscribe(onNext: { [weak self] in
                AuthFirebaseService.shared.updateUserActive(isActive: false)
                Utilitis.shared.setBadgeIcon(number: 0)
                var fcm = self?.settingViewModel.user.fcmToken ?? []
                let fcmToken = UserDefaultManager.shared.getNotificationToken()
                print("token", fcmToken)
                fcm.remove(object: fcmToken)
                print("fcm: ", fcm.count)
                AuthFirebaseService.shared.updateFcmToken(fcmToken: fcm)
                UserDefaultManager.shared.setID(id: nil)
                self?.goToSetRootIntroVC()
            })
            .disposed(by: disposeBag)
    }

    @IBAction func btnChangeAvataTapped(_ sender: Any) {
        self.showAlertOptions()
    }
    @IBAction func btnPlusTapped(_ sender: Any) {
        self.showAlertOptions()
    }
    
    func showAlertOptions() {
        let alert = UIAlertController(title: "Choose Options", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
            self?.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Avata Detail", style: .default, handler: { [weak self] _ in
            self?.openDetailAvata()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func openCamera() {
        let filterVC = FilterViewController()
        filterVC.delegate = self
        filterVC.titleButonSend = "Update"
        filterVC.modalPresentationStyle = .fullScreen
        self.present(filterVC, animated: true, completion: nil)
    }
    
    private func openDetailAvata() {
        guard let image = self.imvAvata.image else {
            return
        }
    }
}

extension SettingViewController: CameraProtocol {
    func didSendImageCaptured(image: UIImage) {
        self.settingViewModel.updateAvata(image: image)
            .subscribe(onNext: { [weak self] url in
                self?.imvAvata.image = image
            })
            .disposed(by: disposeBag)
    }
}
