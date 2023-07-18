//
//  DetailImageViewController.swift
//  IntergrateMLModel
//
//  Created by Khanh Vu on 07/04/5 Reiwa.
//

import UIKit
import SnapKit
import Photos
import ProgressHUD

class DetailImageView: UIView {

    private lazy var imvDetail: UIImageView = {
        let imv = UIImageView()
        imv.contentMode = .scaleAspectFit
        imv.backgroundColor = RCValues.shared.color(forKey: .backgroundColor)
        imv.addConnerRadius(radius: 20)
        return imv
    }()
    
    private lazy var btnCancel: UIButton = {
        let btn = UIButton()
        btn.setImage(Constants.Image.backButtonSystem, for: .normal)
        btn.tintColor = .white
        btn.addTarget(self, action: #selector(btnCancelImageTapped), for: .touchUpInside)
        return btn
    }()
    
    private lazy var btnDownload: UIButton = {
        let btn = UIButton()
        btn.setImage(Constants.Image.downloadSystem, for: .normal)
        btn.tintColor = .white
        btn.addTarget(self, action: #selector(btnDownloadTapped), for: .touchUpInside)
        return btn
    }()
    
    private lazy var btnSendImage: UIButton = {
        let btn = UIButton()
        btn.setTitle("Send", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.backgroundColor = .white
        btn.addConnerRadius(radius: 10)
        btn.addTarget(self, action: #selector(btnSendImageTapped), for: .touchUpInside)
        return btn
    }()
    
    private lazy var vContent: UIView = {
        let v = UIView()
        [imvDetail, btnCancel, btnDownload].forEach { sub in
            v.addSubview(sub)
        }
        v.addConnerRadius(radius: 20)
        v.backgroundColor = .clear
        return v
    }()
    
    private lazy var vPopupSaved: PopupSavedView = {
        let v = PopupSavedView()
        v.isHidden = true
        return v
    }()
    

    var maxWidth: CGFloat = 0.0
    var maxHeight: CGFloat = 0.0

    var actionCancelTapped: (() -> Void)?
    var actionSendImageTapped: ((UIImage) -> Void)?
    init() {
        super.init(frame: .zero)
        self.setUpView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setUpView() {
        self.backgroundColor = RCValues.shared.color(forKey: .backgroundColor)
        [vContent, btnSendImage, vPopupSaved].forEach { sub in
            self.addSubview(sub)
        }
        self.vContent.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(self.vContent.snp.width).multipliedBy(1920.0/1080.0)
        }
        self.btnCancel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.width.height.equalTo(50)
            make.leading.equalToSuperview().offset(10)
        }
        self.btnDownload.snp.makeConstraints { make in
            make.top.equalTo(btnCancel)
            make.width.height.equalTo(btnCancel)
            make.trailing.equalToSuperview().offset(-20)
        }
        self.btnSendImage.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(self.vContent.snp.bottom).offset(10)
            make.trailing.equalToSuperview().offset(-15)
            make.height.equalTo(35)
            make.width.equalTo(80)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        vPopupSaved.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.height.equalTo(self.vPopupSaved.popupWidth)
        }
    }
    
    func configImage(image: UIImage) {
        self.maxWidth = self.vContent.frame.width
        self.maxHeight = self.vContent.frame.height
        
        let ratio = image.size.height/image.size.width
        self.imvDetail.snp.removeConstraints()
        print(maxWidth)
        print(maxHeight)
        if ratio <= 1920.0/1080.0 {
            self.imvDetail.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview()
                make.centerY.equalToSuperview()
                make.height.equalTo(maxWidth * ratio)
            }
        } else {
            self.imvDetail.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview()
                make.centerX.equalToSuperview()
                make.width.equalTo(maxHeight / ratio)
            }
        }
        self.imvDetail.image = image
    }
    
    func configBtnSend(isHidden: Bool, btnTitle: String? = "Send") {
        self.btnSendImage.setTitle(btnTitle, for: .normal)
        self.btnSendImage.isHidden = isHidden
    }
    
    @objc func btnCancelImageTapped() {
        if let actionCancelTapped = self.actionCancelTapped {
            actionCancelTapped()
        }
    }
    
    @objc func btnDownloadTapped() {
        guard let image = imvDetail.image else {
            print("Can't not fetch Image to Save!")
            return
        }
        ProgressHUD.show()
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: image)
        }) { saved, error in
            guard error == nil  else {
                self.makeToast("Error saving image to library: \(error!.localizedDescription)")
                return
            }
            DispatchQueue.main.async {
                ProgressHUD.dismiss()
                self.vPopupSaved.isHidden = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.vPopupSaved.isHidden = true
                }
            }
        }
    }
    
    @objc func btnSendImageTapped() {
        if let actionSendImageTapped = actionSendImageTapped, let image = imvDetail.image {
            actionSendImageTapped(image)
        }
    }
}
