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

    private lazy var detailView: DetailImageView = {
        detailView = DetailImageView()
        detailView.delegate = self
        detailView.isHidden = true
        return detailView
    }()
    private lazy var vPopupSaved: PopupSavedView = {
        let v = PopupSavedView()
        v.isHidden = true
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpView()
        self.settingViewModel.getInfoUser()
        self.bindingToViewModel()
        // Do any additional setup after loading the view.
    }
    
    func setUpView() {
        [self.detailView, self.vPopupSaved].forEach { sub in
            self.view.addSubview(sub)
        }
        self.detailView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(10)
            make.leading.equalTo(self.view.safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(self.view.safeAreaLayoutGuide.snp.trailing)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
        self.vPopupSaved.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.height.equalTo(self.vPopupSaved.popupWidth)
        }
        self.detailView.configBtnSend(isHidden: true)
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
            self.goToSetRootIntroVC()
        }
    }

    @IBAction func btnChangeAvataTapped(_ sender: Any) {
        self.showAlertOptions()
    }
    @IBAction func btnPlusTapped(_ sender: Any) {
        self.showAlertOptions()
    }
    
    func showAlertOptions() {
        let alert = UIAlertController(title: "Choose Options", message: nil, preferredStyle: .actionSheet)
               alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
                   self.openCamera()
               }))

               alert.addAction(UIAlertAction(title: "Avata Detail", style: .default, handler: { _ in
                   self.openDetailAvata()
               }))

               alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))

               self.present(alert, animated: true, completion: nil)
    }
    
    private func openCamera() {
        let filterVC = FilterViewController()
        filterVC.delegate = self
        filterVC.modalPresentationStyle = .fullScreen
        self.present(filterVC, animated: true, completion: nil)
    }
    
    private func openDetailAvata() {
        guard let image = self.imvAvata.image else {
            return
        }
        self.detailView.configImage(image: image)
        self.detailView.isHidden = false
        self.view.backgroundColor = UIColor(hexString: "#242121")
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

extension SettingViewController: DetailImageViewProtocol {
    func btnSendImageTapped(image: UIImage) {
    }
    
    func btnCancelImageTapped() {
        self.detailView.isHidden = true
        self.view.backgroundColor = .white
    }
    
    func btnDownloadTapped(image: UIImage) {
        self.showActivityIndicator()
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }) { saved, error in
            guard error == nil  else {
                self.view.makeToast("Error saving image to library: \(error!.localizedDescription)")
                return
            }
            DispatchQueue.main.async {
                self.hideActivityIndicator()
                self.vPopupSaved.isHidden = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.vPopupSaved.isHidden = true
                }
            }
        }
    }
}
