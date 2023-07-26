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
import FirebaseCoreInternal
class SettingViewController: BaseViewController {
    @IBOutlet weak var imvAvata: UIImageView!
    @IBOutlet weak var btnChangeAvata: UIButton!
    @IBOutlet weak var btnPlus: UIButton!
    @IBOutlet weak var lbUsername: UILabel!
    @IBOutlet weak var lbAvata: UILabel!
    
    
    let settingViewModel = SettingViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    override func setUpUI() {
        self.imvAvata.addConnerRadius(radius: self.imvAvata.frame.width/2)
        self.imvAvata.addBorder(borderWidth: 8, borderColor: .black)
        
        self.btnPlus.addConnerRadius(radius: self.btnPlus.frame.width/2)
        self.btnPlus.addBorder(borderWidth: 2, borderColor: .black)
        self.btnPlus.backgroundColor = RCValues.shared.color(forKey: .appPrimaryColor)
        self.btnChangeAvata.addConnerRadius(radius: self.btnChangeAvata.frame.width/2)
        self.btnChangeAvata.addBorder(borderWidth: 4, borderColor: RCValues.shared.color(forKey: .appPrimaryColor))
        self.lbAvata.textColor = RCValues.shared.color(forKey: .appPrimaryColor)
    }
    
    override func bindViewModel() {
        
        self.settingViewModel.getInfoUser()
            .drive(onNext: { [weak self] user in
                self?.settingViewModel.user = user
                self?.imvAvata.setImage(urlString: user.avataURL ?? "", placeHolder: Constants.Image.defaultAvataImage)
                self?.lbUsername.text = user.username
                self?.lbAvata.text = user.username?.getInitials()
                if let avataURL = URL(string: user.avataURL ?? "") {
                    self?.imvAvata.sd_setImage(with: avataURL, placeholderImage: Constants.Image.defaultAvataImage)
                    self?.lbAvata.isHidden = true
                } else {
                    self?.imvAvata.image = nil
                    self?.lbAvata.isHidden = false
                }
            })
            .disposed(by: disposeBag)
    }
    override func setImageFromImagePicker(image: UIImage) {
        self.settingViewModel.updateAvata(image: image)
            .subscribe(onNext: { [weak self] url in
                self?.imvAvata.image = image
            })
            .disposed(by: self.disposeBag)
    }
    
    @IBAction func btnLogOutTapped(_sender: UIButton) {
        self.settingViewModel.handleLogOut()
            .subscribe(onNext: { [weak self] in
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
        alert.addAction(UIAlertAction(title: "Library", style: .default, handler: { [weak self] _ in
            self?.openLibrary()
        }))
        if imvAvata.image != nil {
            alert.addAction(UIAlertAction(title: "Remove avata", style: .default) { [weak self] _ in
                self?.removeAvata()
            })
        }
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func openCamera() {
        let filterVC = FilterViewController()
        filterVC.modalPresentationStyle = .fullScreen
        filterVC.actionSendImage = { [weak self] image in
            guard let strongSelf = self else {
                return
            }
            strongSelf.settingViewModel.updateAvata(image: image)
                .subscribe(onNext: { [weak self] url in
                    self?.imvAvata.image = image
                })
                .disposed(by: strongSelf.disposeBag)
        }
        self.present(filterVC, animated: false, completion: nil)
    }
    
    private func removeAvata() {
        self.imvAvata.image = nil
        self.lbAvata.isHidden = false
        FirebaseService.shared.updateAvatar(url: "")
    }
}

