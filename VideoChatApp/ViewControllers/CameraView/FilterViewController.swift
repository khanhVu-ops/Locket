//
//  FilterViewController.swift
//  IntergrateMLModel
//
//  Created by Khanh Vu on 26/03/5 Reiwa.
//

import UIKit
import SnapKit
import AVFoundation
import Vision

class FilterViewController: BaseViewController {

    private lazy var btnCancel: UIButton = {
        let btn = UIButton()
        btn.setImage(Constants.Image.cancelSystem, for: .normal)
        btn.tintColor = .white
        btn.addTarget(self, action: #selector(btnCancelTapped(_:)), for: .touchUpInside)
        return btn
    }()
    
    private lazy var vTop: UIView = {
        let v = UIView()
        v.addSubview(btnCancel)
        v.backgroundColor = .clear
        return v
    }()
    
    private lazy var vContent: UIView = {
        let v = UIView()
        [cameraView, detailView].forEach { sub in
            v.addSubview(sub)
        }
        v.backgroundColor = .clear
        return v
    }()
    
    private lazy var stvBottom: UIStackView = {
        let stv = UIStackView()
        return stv
    }()
    
    private lazy var vAction: UIView = {
        let v = UIView()
        [imvLibrary, vCapture, btnReloadCamera].forEach { sub in
            v.addSubview(sub)
        }
        v.backgroundColor = .clear
        return v
    }()
    
    private lazy var vCapture: CustomCaptureButton = {
        let vCapture = CustomCaptureButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        return vCapture
    }()

    
    private lazy var imvLibrary: UIImageView = {
        let imv = UIImageView()
        imv.addConnerRadius(radius: 10)
        imv.addBorder(borderWidth: 2, borderColor: .white)
        imv.contentMode = .scaleAspectFill
        imv.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(btnLibraryTapped(_:))))
        imv.isUserInteractionEnabled = true
        return imv
    }()
    
    private lazy var btnReloadCamera: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .clear
        btn.setBackgroundImage(Constants.Image.reloadSystem, for: .normal)
        btn.tintColor = .white
        btn.addConnerRadius(radius: 10)
        btn.addTarget(self, action: #selector(btnReloadTapped(_:)), for: .touchUpInside)
        btn.isHidden = true
        return btn
    }()

    private lazy var stvAction: UIStackView = {
        let stv = UIStackView()
        [vAction].forEach { sub in
            stv.addArrangedSubview(sub)
        }
        stv.distribution = .equalCentering
        stv.axis = .vertical
        stv.alignment = .fill
        stv.spacing = 10
        return stv
    }()
    
    private var cameraView = CameraView(cameraType: .photo)
    private var detailView = DetailImageView()
    var isCaptured = false
    let viewModel = FilterViewModel()
    var leadTrailingVContentConstraint: Constraint?
    var actionSendImage: ((UIImage) -> Void)?
    var imageCaptured: UIImage?
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.cameraView.startSession()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.cameraView.setUpPreviewLayer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.cameraView.stopSession()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let vContentSize = vContent.frame.size
        let ratio = vContentSize.height/vContentSize.width
        print(CGFloat(4.0/3.0))
        if ratio > CGFloat(4.0/3.0) {
            self.vContent.snp.makeConstraints { make in
                make.height.equalTo(self.vContent.snp.width).multipliedBy(4.0/3.0)
            }
        } else if ratio < 4.0/3.0 {
            leadTrailingVContentConstraint?.deactivate()
            self.vContent.snp.makeConstraints { make in
                make.width.equalTo(self.vContent.snp.height).multipliedBy(3.0/4.0)
                make.centerX.equalToSuperview()
            }
        }
    }
    
    // set up view hiển thị
    override func setUpUI() {
        self.view.backgroundColor = UIColor(hexString: "#242121")
        self.cameraView.isHidden = false
        self.detailView.isHidden = true
        [vTop, vContent, stvAction].forEach { sub in
            self.view.addSubview(sub)
        }
        self.vTop.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.height.equalTo(60)
        }
        self.vContent.snp.makeConstraints { make in
            leadTrailingVContentConstraint = make.leading.trailing.equalToSuperview().inset(5).constraint
            make.top.equalTo(self.vTop.snp.bottom)
        }
        
        self.stvAction.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(self.vContent.snp.bottom).offset(20)
            make.bottom.greaterThanOrEqualTo(self.view.safeAreaLayoutGuide)
        }
        self.vAction.snp.makeConstraints { make in
            make.height.equalTo(90)
        }
        self.btnCancel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.width.equalTo(self.btnCancel.snp.height)
            make.trailing.equalToSuperview().offset(-10)
        }
        self.cameraView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
        self.detailView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalTo(self.cameraView)
        }
        self.vCapture.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.height.equalTo(90)
        }
        self.btnReloadCamera.snp.makeConstraints { make in
            make.width.height.equalTo(40)
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
        }
        self.imvLibrary.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
        }
    }
    
    override func bindEvent() {
        self.requestPermissionAccessPhotos { [weak self] isAccess in
            guard let strongSelf = self else {
                return
            }
            if isAccess {
                strongSelf.viewModel.fetchFirstAssets(imageSize: strongSelf.imvLibrary.frame.size) { [weak self] image in
                    DispatchQueue.main.async {
                        self?.imvLibrary.image = image
                    }
                }
            } else {
                self?.showAlertOpenSettingPhotos()
            }
        }
        
        self.vCapture.actionTapEnter = { [weak self] in
            if self?.isCaptured == false {
                if self?.cameraView.outputType == .video {
                    self?.cameraView.isCapture = true
                } else {
                    self?.cameraView.handleCapturePhoto()
                }
            } else {
                guard let actionSendImage = self?.actionSendImage, let imageCaptured = self?.imageCaptured else {
                    return
                }
                actionSendImage(imageCaptured)
                self?.dismiss(animated: true, completion: nil)
            }
        }
        
        self.cameraView.actionShowAlertSettingCamera = { [weak self] in
            self?.showAlertOpenSettingCamera()
        }
        
        self.cameraView.actionShowAlertWithMessage = { [weak self] message in
            self?.showAlert(title: "App", message: message)
        }
        
        self.cameraView.actionCaptureImage = { [weak self] image in
            self?.updateDetailView(image: image)
        }
    }
    
    override func setImageFromImagePicker(image: UIImage) {
        self.updateDetailView(image: image)
    }
    
    @objc func btnCancelTapped(_ sender: UIButton) {
        sender.dimButton()
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func btnLibraryTapped(_ sender: UIButton) {
        sender.dimButton()
        self.openLibrary()
    }
    
    @objc func btnReloadTapped(_ sender: UIButton) {
        sender.dimButton()
        self.updateUIWhenCaptured(isCaptured: false)
    }
    
    func updateUIWhenCaptured(isCaptured: Bool) {
        self.cameraView.isHidden = isCaptured
        self.detailView.isHidden = !isCaptured
        self.isCaptured = isCaptured
        self.vCapture.showCheckMark(isShow: isCaptured)
        self.imvLibrary.isHidden = isCaptured
        self.btnReloadCamera.isHidden = !isCaptured
    }
    
    func updateDetailView(image: UIImage) {
        DispatchQueue.main.async {
            self.detailView.setImage(with: image)
            self.imageCaptured = image
            self.updateUIWhenCaptured(isCaptured: true)
        }
    }
}
