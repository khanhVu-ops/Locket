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

//    private var coremlRequest: VNCoreMLRequest?
//    private var imgCaptured: UIImage?
//
    private var cameraView: CameraView!
    private var detailView: DetailImageView!
    weak var delegate: CameraProtocol?
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
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension FilterViewController: DetailImageViewProtocol {
    func btnSendImageTapped(image: UIImage) {
        self.delegate?.didSendImageCaptured(image: image)
    }
    
    func btnCancelImageTapped() {
        self.detailView.isHidden = true
        self.cameraView.isHidden = false
    }
    
    func btnDownloadTapped() {
        print("down")
    }

}
    
//
//    private func predict() {
//        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
//            guard let model = try? VNCoreMLModel(for: u2netp(configuration: MLModelConfiguration()).model) else {
//                fatalError("Model initilation failed!")
//            }
//            let coremlRequest = VNCoreMLRequest(model: model)
//            coremlRequest.imageCropAndScaleOption = .scaleFill
//            self?.coremlRequest = coremlRequest
//        }
//
//    }
//
//    func handleRequest(imgCropped: UIImage){
//        guard let coremlRequest = self.coremlRequest else {
//            return
//        }
//
//        let handler = VNImageRequestHandler(cgImage: imgCropped.cgImage!, options: [:])
//            do {
//                try handler.perform([coremlRequest])
//                guard let result = coremlRequest.results?.first as? VNPixelBufferObservation else { return }
//                let output = result.pixelBuffer
//                let maskImage = self.convertCVPixelBufferToUIImage(pixelBuffer: output)
//                let cropImg = self.processRemoveObjectImage(originalImage: imgCropped, maskImage: maskImage)
//
//            }catch {
//                fatalError("Inference error \(error)")
//            }
//    }
//
//    func convertCVPixelBufferToUIImage(pixelBuffer: CVPixelBuffer) -> UIImage {
//        let ciimage : CIImage = CIImage(cvPixelBuffer: pixelBuffer)
//        let context:CIContext = CIContext()
//        let cgImage:CGImage = context.createCGImage(ciimage, from: ciimage.extent)!
//        let myImage:UIImage = UIImage(cgImage: cgImage, scale: 1, orientation: .up)
//        return myImage
//    }
//
//    func processRemoveObjectImage(originalImage: UIImage, maskImage: UIImage) -> UIImage {
//        let mainImage = CIImage(cgImage: originalImage.cgImage!)
//        let originalSize = mainImage.extent.size
//        //Convert the maskimage to CIImage and set the size
//        //to be the same as the original
//        var maskCI = CIImage(cgImage: maskImage.cgImage!)
//        let scaleX = originalSize.width / maskCI.extent.width
//        let scaleY = originalSize.height / maskCI.extent.height
//        maskCI = maskCI.transformed(by: .init(scaleX: scaleX, y: scaleY))
//        //Convert the new background to a CIImage and set the size
//        //to be the same as the original
//        let backgroundUIImage = originalImage
//        let background = CIImage(cgImage: backgroundUIImage.cgImage!)
//        //Use CIBlendWithMask to combine the three images
//        let filter = CIFilter(name: "CIBlendWithMask")
//        let inputImg = imageWithColor(color: .white, size: CGSize(width: originalSize.width, height: originalSize.height))
//        filter?.setValue(background, forKey: kCIInputBackgroundImageKey)
//        filter?.setValue(CIImage(cgImage: (inputImg?.cgImage)!) , forKey: kCIInputImageKey)
//        filter?.setValue(maskCI, forKey: kCIInputMaskImageKey)
//        //Update the UI
//        return UIImage(ciImage: filter!.outputImage!)
//    }
//
//    var listPoint: [CGPoint] = []
//    var rectSelected: CGRect?
//    func didTapScreen(_ gesture: UITapGestureRecognizer) {
//        if var imgCaptured = self.imgCaptured {
//            let position = gesture.location(in: self.vPreviewVideo)
//            if listPoint.count < 4 {
//                listPoint.append(position)
//                let canvasSize = CGSize(width: self.vPreviewVideo.frame.width, height: self.vPreviewVideo.frame.height)
//                let changed2 = Painting.draw(image: imgCaptured, canvasSize: canvasSize,fromPoint: position, toPoint: position, lineWidth: 10)
//                self.imgCaptured = changed2
//                print(position)
//            }
//            // draw Rectangle max
//            if listPoint.count == 4 {
//                var xMin = 1000.0, yMin = 1000.0, xMax = 0.0, yMax = 0.0
//                for p in listPoint {
//                    xMin = min(Double(Int(p.x)), xMin)
//                    yMin = min(Double(Int(p.y)), yMin)
//                    xMax = max(Double(Int(p.x)), xMax)
//                    yMax = max(Double(Int(p.y)), yMax)
//                }
//                if let cgImg = imgCaptured.cgImage {
//                    let canvasSize = CGSize(width: self.vPreviewVideo.frame.width, height: self.vPreviewVideo.frame.height)
//                    let changed1 = Painting.draw(image: imgCaptured,canvasSize: canvasSize,fromPoint: CGPoint(x: xMin, y: yMin), toPoint: CGPoint(x: xMin, y: yMax))
//                    let changed2 = Painting.draw(image: changed1!, canvasSize: canvasSize,fromPoint: CGPoint(x: xMin, y: yMin), toPoint: CGPoint(x: xMax, y: yMin))
//                    let changed3 = Painting.draw(image: changed2!, canvasSize: canvasSize,fromPoint: CGPoint(x: xMax, y: yMin), toPoint: CGPoint(x: xMax, y: yMax))
//                    let changed4 = Painting.draw(image: changed3!, canvasSize: canvasSize,fromPoint: CGPoint(x: xMin, y: yMax), toPoint: CGPoint(x: xMax, y: yMax))
//                    imgCaptured  = changed4!
//                    listPoint = []
//                    let ratioX = CGFloat(imgCaptured.size.width) / self.vPreviewVideo.frame.width
//                    let ratioY = CGFloat(imgCaptured.size.height) / self.vPreviewVideo.frame.height
//
//                    let rectCrop = CGRect(x: xMin*ratioX, y: yMin*ratioY, width: xMax*ratioX - xMin*ratioY, height: yMax*ratioX - yMin*ratioY)
//                    print("RECTCROP: \(rectCrop)")
//                    self.rectSelected = rectCrop
//                    let cropImage = self.cropImage(with: self.imgCaptured!, imageSize: rectCrop)
//
//                    //                        self.imageCaptured = cropImage
//                }
//            }
//
//        }
//
//
//    }
//
//    func cropImage(with image: UIImage, imageSize: CGRect) -> UIImage {
//        let sourceCGImage = image.cgImage!
//        let croppedCGImage = sourceCGImage.cropping(to: imageSize)
//        return UIImage(cgImage: croppedCGImage!, scale: image.scale, orientation: image.imageOrientation)
//    }
//    func imageWithColor(color: UIColor, size: CGSize=CGSize(width: 1, height: 1)) -> UIImage? {
//        UIGraphicsBeginImageContextWithOptions(size, false, 0)
//        color.setFill()
//        UIRectFill(CGRect(origin: CGPoint.zero, size: size))
//        let image = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return image
//    }
//}
