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

class FilterViewController: UIViewController {

    private var cameraView = CameraView(cameraType: .photo)
    private var detailView = DetailImageView()
    var actionSendImage: ((UIImage) -> Void)?
    private var imagePicker = UIImagePickerController()
    
    
    var titleButonSend: String = "Send" {
        didSet {
            self.detailView.configBtnSend(isHidden: false, btnTitle: titleButonSend)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUpView()

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.cameraView.startSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.cameraView.stopSession()
        
    }

    
    func setUpView() {
        self.view.backgroundColor = UIColor(hexString: "#242121")
        self.cameraView.delegate = self
        self.cameraView.isHidden = false
        self.detailView.isHidden = true
        detailView.actionCancelTapped = { [weak self] in
            self?.detailView.isHidden = true
            self?.cameraView.isHidden = false
        }
        detailView.actionSendImageTapped = { [weak self] image in
            if let actionSendImage = self?.actionSendImage {
                actionSendImage(image)
            }
            self?.dismiss(animated: true)
        }
        
        [cameraView, detailView].forEach { sub in
            self.view.addSubview(sub)
        }
        cameraView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview().inset(5)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
        detailView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview().inset(5)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
        
    }
}
extension FilterViewController: CameraViewDelegate {
    func didShowAlert(title: String, message: String) {
        self.showAlert(title: title, message: message)
    }
    
    func didShowAlertSetting() {
        self.showAlertOpenSettingCamera()
    }
    
    func didCapturedImage(imageCaptured: UIImage) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            self.detailView.configImage(image: imageCaptured)
            self.detailView.isHidden = false
            self.cameraView.isHidden = true
        })
    }
    
    func btnCancelTapped() {
        self.dismiss(animated: true)
    }
    
    func btnLibraryTapped() {
        self.imagePicker.delegate = self
        self.imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
//        let photosVC = PhotosViewController()
//        photosVC.delegate = self
//        self.present(photosVC, animated: true, completion: nil)
    }
    
}

extension FilterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let img = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        guard let image = img else {
            return
        }
        self.detailView.configImage(image: image)
        self.detailView.isHidden = false
        self.cameraView.isHidden = true

        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

