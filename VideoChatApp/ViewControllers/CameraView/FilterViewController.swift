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

protocol CameraProtocol: NSObject {
    func didSendImageCaptured(image: UIImage)
}
class FilterViewController: UIViewController {

    private var cameraView: CameraView!
    private var detailView: DetailImageView!
    weak var delegate: CameraProtocol?
    private var imagePicker = UIImagePickerController()

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
        self.cameraView = CameraView(cameraType: .photo)
        self.cameraView.delegate = self
        self.cameraView.isHidden = false
        self.detailView = DetailImageView()
        self.detailView.delegate = self
        self.detailView.isHidden = true
        [cameraView, detailView].forEach { sub in
            self.view.addSubview(sub)
        }
        cameraView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(self.view.snp.leading)
            make.trailing.equalTo(self.view.snp.trailing)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
        detailView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(self.view.snp.leading)
            make.trailing.equalTo(self.view.snp.trailing)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
    }
}
extension FilterViewController: CameraViewDelegate {
    func didShowAlert(title: String, message: String) {
        self.showAlert(title: title, message: message)
    }
    
    func didShowAlertSetting(title: String, message: String) {
        self.showAlertSetting(title: title, message: message)
    }
    
    func didCapturedImage(imageCaptured: UIImage) {
        self.detailView.configImage(image: imageCaptured)
        self.detailView.isHidden = false
        self.cameraView.isHidden = true
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

extension FilterViewController: DetailImageViewProtocol {
    func btnSendImageTapped(image: UIImage) {
        self.delegate?.didSendImageCaptured(image: image)
        self.dismiss(animated: true)
    }
    
    func btnCancelImageTapped() {
        self.detailView.isHidden = true
        self.cameraView.isHidden = false
    }
    
    func btnDownloadTapped() {
        print("down")
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
//        self.imvAvata.image = image

        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

