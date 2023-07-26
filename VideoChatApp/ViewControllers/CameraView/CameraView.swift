//
//  CameraViewController.swift
//  FlowerClassification
//
//  Created by Khanh Vu on 30/03/5 Reiwa.
//

//
//  ViewController.swift
//  IntergrateMLModel
//
//  Created by Khanh Vu on 24/03/5 Reiwa.
//

import UIKit
import SnapKit
import AVFoundation
import CoreMotion
import Vision
import Photos
import Toast_Swift
enum OutputType {
    case video
    case photo
    case portrait
}

class CameraView: UIView {
    
    lazy var vPreviewVideo: UIView = {
        let v = UIView()
        v.layer.cornerRadius = 20
        v.layer.masksToBounds = true
        v.backgroundColor = .white
        return v
    }()
    
    private var vOverlay: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        v.layer.borderWidth = 1.5
        v.layer.borderColor = UIColor.orange.cgColor
        return v
    }()
    
    private lazy var btnSwitchCamera: UIButton = {
        let btn = UIButton()
        btn.addTarget(self, action: #selector(btnSwitchcameraTapped), for: .touchUpInside)
        btn.setImage(Constants.Image.switchCameraSystem, for: .normal)
        btn.tintColor = .white
        btn.backgroundColor = .clear.withAlphaComponent(0.1)
        return btn
    }()
    
    private lazy var btnFlash: UIButton = {
        let btn = UIButton()
        btn.setImage(Constants.Image.flashSlashSystem, for: .normal)
        btn.addTarget(self, action: #selector(btnFlashTapped), for: .touchUpInside)
        btn.tintColor = .white
        btn.backgroundColor = .clear.withAlphaComponent(0.1)
        return btn
    }()
    
   
    
    var session = AVCaptureSession()
    var previewLayer = AVCaptureVideoPreviewLayer()
    var photoOutput : AVCapturePhotoOutput!
    var videoOutput: AVCaptureVideoDataOutput!
    var videoDeviceInput: AVCaptureDeviceInput!
    
    var outputType = OutputType.photo
    var flash: AVCaptureDevice.FlashMode = .off
    var isCapture = false
    private let sessionQueue = DispatchQueue(label: "session queue")// Communicate with the session and other session objects on this queue.
    private var setupResult: SessionSetupResult = .success
    private let videoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera], mediaType: .video, position: .unspecified)
    
    var actionShowAlertSettingCamera: (() -> Void)?
    var actionShowAlertWithMessage: ((String) -> Void)?
    var actionCaptureImage: ((UIImage) -> Void)?
    var actionGetFrameCamera:((CVPixelBuffer) -> Void)?
    
    init(cameraType: OutputType) {
        super.init(frame: .zero)
        self.outputType = cameraType
        self.previewLayer.session = self.session
        self.checkPermissions()
        self.configView()
        sessionQueue.async {
            self.configureSession()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.btnSwitchCamera.circleClip()
        self.btnFlash.circleClip()
    }
    
    func configView() {
        self.backgroundColor = .clear
        [self.vPreviewVideo, self.btnSwitchCamera, self.btnFlash].forEach { subView in
            self.addSubview(subView)
        }
        self.vPreviewVideo.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
        
        self.btnSwitchCamera.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.width.height.equalTo(40)
            make.trailing.equalToSuperview().offset(-10)
        }
        self.btnFlash.snp.makeConstraints { make in
            make.top.equalTo(self.btnSwitchCamera.snp.bottom).offset(20)
            make.width.height.equalTo(40)
            make.centerX.equalTo(self.btnSwitchCamera)
        }
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        self.addGestureRecognizer(pinchGesture)
    }
    
    private func configureSession() {
        if setupResult != .success {
            return
        }
        self.session.beginConfiguration()
        self.session.sessionPreset = .photo
        // Add input.
        self.setUpCamera()

        //Add ouput
        switch outputType {
        case .video:
            self.setupVideoOutput()
        default:
            self.setUpPhotoOutput()
        }
        
        self.session.commitConfiguration()
        
        self.session.startRunning()
    }
    
    func startSession() {
        sessionQueue.async {
            switch self.setupResult {
            case .success:
                self.session.startRunning()
            case .notAuthorized:
                if let actionShowAlertSettingCamera = self.actionShowAlertSettingCamera {
                    actionShowAlertSettingCamera()
                }
            case .configurationFailed:
                if let actionShowAlertWithMessage = self.actionShowAlertWithMessage {
                    actionShowAlertWithMessage("Config input camera failed!")
                }
            }
        }
        
    }
    
    func stopSession() {
        sessionQueue.async {
            if self.setupResult == .success {
                self.session.stopRunning()
            }
        }
    }
    
    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            // The user has previously granted access to the camera.
            break
        case .notDetermined:
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                if !granted {
                    self.setupResult = .notAuthorized
                }
                self.sessionQueue.resume()
            })
        default:
            // The user has previously denied access.
            setupResult = .notAuthorized
        }
    }
    
    func setUpCamera() {
        do {
            var defaultVideoDevice: AVCaptureDevice?
            // Choose the back dual camera if available, otherwise default to a wide angle camera.
            switch outputType {
            case .portrait:
                guard let backCameraDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) else {
                    if let actionShowAlertWithMessage = actionShowAlertWithMessage {
                        actionShowAlertWithMessage("No Camera Portrait!")
                    }
                    return
                }
                defaultVideoDevice = backCameraDevice
            default :
                if let backCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
                    // If the back dual camera is not available, default to the back wide angle camera.
                    defaultVideoDevice = backCameraDevice
                } else if let frontCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
                    defaultVideoDevice = frontCameraDevice
                }
            }
            guard let defaultVideoDevice = defaultVideoDevice else {
                DispatchQueue.main.async {
                    self.makeToast("Can't not detect camera from this device!")
                }
                return
            }

            let videoDeviceInput = try AVCaptureDeviceInput(device: defaultVideoDevice)
            if self.session.canAddInput(videoDeviceInput) {
                self.session.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
                
                //                DispatchQueue.main.async {
                //                    /*
                //                        Why are we dispatching this to the main queue?
                //                        Because AVCaptureVideoPreviewLayer is the backing layer for PreviewView and UIView
                //                        can only be manipulated on the main thread.
                //                        Note: As an exception to the above rule, it is not necessary to serialize video orientation changes
                //                        on the AVCaptureVideoPreviewLayer’s connection with other session manipulation.
                //
                //                        Use the status bar orientation as the initial video orientation. Subsequent orientation changes are
                //                        handled by CameraViewController.viewWillTransition(to:with:).
                //                    */
                //                    let statusBarOrientation = UIApplication.shared.statusBarOrientation
                //                    var initialVideoOrientation: AVCaptureVideoOrientation = .portrait
                //                    if statusBarOrientation != .unknown {
                //                        if let videoOrientation = AVCaptureVideoOrientation(interfaceOrientation: statusBarOrientation) {
                //                            initialVideoOrientation = videoOrientation
                //                        }
                //                    }
                //
                //                    self.previewLayer.connection?.videoOrientation = initialVideoOrientation
                //                }
            } else {
                print("Could not add video device input to the session")
                setupResult = .configurationFailed
                self.session.commitConfiguration()
                return
            }
        } catch {
            print("Could not create video device input: \(error)")
            self.setupResult = .configurationFailed
            self.session.commitConfiguration()
            return
        }
    }
    
    //MARK: Set up output
    func setUpPreviewLayer() {
        self.previewLayer.videoGravity = .resizeAspectFill
        self.vPreviewVideo.layer.insertSublayer(self.previewLayer, above: self.vPreviewVideo.layer)
        self.previewLayer.frame = self.vPreviewVideo.bounds
        self.vPreviewVideo.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapHandleFocus)))
    }
    
    func setupVideoOutput(){
        self.videoOutput = AVCaptureVideoDataOutput()
        self.videoOutput.alwaysDiscardsLateVideoFrames = true
        let videoQueue = DispatchQueue(label: "videoQueue", qos: .userInteractive)
        self.videoOutput.setSampleBufferDelegate(self, queue: videoQueue)
        if self.session.canAddOutput(self.videoOutput) {
            self.session.addOutput(self.videoOutput)
        } else {
            print("could not add video output")
            self.setupResult = .configurationFailed
            self.session.commitConfiguration()
        }
        self.videoOutput.connections.first?.videoOrientation = .portrait
    }
    
    func setUpPhotoOutput() {
        self.photoOutput = AVCapturePhotoOutput()
        if self.session.canAddOutput(self.photoOutput) {
            self.session.addOutput(self.photoOutput)
            self.photoOutput.isHighResolutionCaptureEnabled = true
            self.photoOutput.isLivePhotoCaptureEnabled = self.photoOutput.isLivePhotoCaptureSupported
            self.photoOutput.isDepthDataDeliveryEnabled = self.photoOutput.isDepthDataDeliverySupported
        } else {
            print("Could not add photo output to the session")
            self.setupResult = .configurationFailed
            self.session.commitConfiguration()
            return
        }
    }
    
    //MARK: @objc func
    var zoomCamera = 1.0
    @objc func handlePinch(_ gestureRecognizer: UIPinchGestureRecognizer) {
        let camera = self.videoDeviceInput.device
        if gestureRecognizer.state == .began {
            print("began")
        } else if gestureRecognizer.state == .changed {
            do {
                try camera.lockForConfiguration()
                let scale = gestureRecognizer.scale
                var zoomFactor = 0.0
                if scale < 1 && self.zoomCamera > 1{
                    zoomFactor = self.zoomCamera * scale
                } else {
                    zoomFactor = self.zoomCamera * scale
                }
                zoomFactor = max(1.0, min(zoomFactor, 10))
                camera.videoZoomFactor = zoomFactor
                camera.unlockForConfiguration()
            }catch {
                print(error)
            }
        } else {
            self.zoomCamera = camera.videoZoomFactor
        }
 
    }
    
    @objc func tapHandleFocus(_ gestureRecognizer: UITapGestureRecognizer) {
        let point = gestureRecognizer.location(in: gestureRecognizer.view)
        self.addSquareWhenTapFocus(point: point)
        let devicePoint = previewLayer.captureDevicePointConverted(fromLayerPoint: point)
        focus(with: .autoFocus, exposureMode: .autoExpose, at: devicePoint, monitorSubjectAreaChange: true)
        
    }
    
    @objc func btnFlashTapped(_ sender: UIButton) {
        sender.dimButton()
        switch self.outputType {
        case .video:
            let device = self.videoDeviceInput.device
            guard device.isTorchAvailable else {
                return
            }
            do {
                try device.lockForConfiguration()
                if device.torchMode == .off {
                    self.btnFlash.setImage(Constants.Image.flashSystem, for: .normal)
                    device.torchMode = .on
                    try device.setTorchModeOn(level: 0.7)
                } else {
                    self.btnFlash.setImage(Constants.Image.flashSlashSystem, for: .normal)
                    device.torchMode = .off
                }
                device.unlockForConfiguration()
                
            } catch {
                debugPrint(error)
            }
        default:
            if flash == .off {
                self.btnFlash.setImage(Constants.Image.flashSystem, for: .normal)
                flash = .on
            } else {
                self.btnFlash.setImage(Constants.Image.flashSlashSystem, for: .normal)
                flash = .off
            }
        
        }
        
    }
    
    func isHiddenIconFlast(isHidden: Bool) {
        if outputType == .video {
            DispatchQueue.main.async {
                self.btnFlash.isHidden = isHidden
            }
        }
    }
    @objc func btnSwitchcameraTapped(_ sender: UIButton) {
        sender.dimButton()
        sessionQueue.async {
            let currentVideoDevice = self.videoDeviceInput.device
            let currentPosition = currentVideoDevice.position
            
            let preferredPosition: AVCaptureDevice.Position
            let preferredDeviceType: AVCaptureDevice.DeviceType
            
            switch currentPosition {
            case .unspecified, .front:
                preferredPosition = .back
                preferredDeviceType = .builtInDualCamera
                self.isHiddenIconFlast(isHidden: false)
            case .back:
                preferredPosition = .front
                preferredDeviceType = .builtInWideAngleCamera
                self.isHiddenIconFlast(isHidden: true)
            }
            
            let devices = self.videoDeviceDiscoverySession.devices
            var newVideoDevice: AVCaptureDevice? = nil
            
            // First, look for a device with both the preferred position and device type. Otherwise, look for a device with only the preferred position.
            if let device = devices.first(where: { $0.position == preferredPosition && $0.deviceType == preferredDeviceType }) {
                newVideoDevice = device
            } else if let device = devices.first(where: { $0.position == preferredPosition }) {
                newVideoDevice = device
            }
            
            if let videoDevice = newVideoDevice {
                do {
                    let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
                    
                    self.session.beginConfiguration()
                    
                    // Remove the existing device input first, since using the front and back camera simultaneously is not supported.
                    self.session.removeInput(self.videoDeviceInput)
                    
                    if self.session.canAddInput(videoDeviceInput) {
                        self.session.addInput(videoDeviceInput)
                        self.videoDeviceInput = videoDeviceInput
                    } else {
                        self.session.addInput(self.videoDeviceInput)
                    }
                    switch self.outputType {
                    case .video:
                        self.videoOutput.connections.first?.videoOrientation = .portrait
                    default:
                        self.photoOutput.isLivePhotoCaptureEnabled = self.photoOutput.isLivePhotoCaptureSupported
                        self.photoOutput.isDepthDataDeliveryEnabled = self.photoOutput.isDepthDataDeliverySupported
                    }
                    self.session.commitConfiguration()
                } catch {
                    print("Error occured while creating video device input: \(error)")
                }
            }
        }
    }
    
    private func focus(with focusMode: AVCaptureDevice.FocusMode, exposureMode: AVCaptureDevice.ExposureMode, at devicePoint: CGPoint, monitorSubjectAreaChange: Bool) {
        sessionQueue.async {
            let device = self.videoDeviceInput.device
            do {
                try device.lockForConfiguration()
                if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(focusMode) {
                    device.focusPointOfInterest = devicePoint
                    device.focusMode = focusMode
                }
                if device.isExposurePointOfInterestSupported && device.isExposureModeSupported(exposureMode) {
                    device.exposurePointOfInterest = devicePoint
                    device.exposureMode = exposureMode
                }
                device.isSubjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange
                device.unlockForConfiguration()
            } catch {
                print("Could not lock device for configuration: \(error)")
            }
        }
    }
    
    func handleCapturePhoto() {
        DispatchQueue.main.async {
            let photoSettings = AVCapturePhotoSettings()
            photoSettings.flashMode = self.flash
            self.photoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }
}

extension CameraView: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let cvPixel = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        if let actionGetFrameCamera = self.actionGetFrameCamera {
            actionGetFrameCamera(cvPixel)
        }
        if self.isCapture {
            self.isCapture = false
            var img: UIImage?
            switch self.videoDeviceInput.device.position {
            case .front :
                img = convertToFlipImage(pixelBuffer: cvPixel)
            default:
                img = convertToUIImage(pixelBuffer: cvPixel)
            }
            guard let img = img, let actionCaptureImage = actionCaptureImage else {
                return
            }
            actionCaptureImage(img)
        }
    }
}

extension CameraView: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else {
            return
        }
        guard let capturedImage = UIImage(data: imageData)  else {
            return
        }
        var img: UIImage!
        switch self.videoDeviceInput.device.position {
        case .back :
            img = capturedImage
        default:
            img = UIImage(cgImage: capturedImage.cgImage!, scale: capturedImage.scale, orientation: .leftMirrored)
        }
        if let actionCaptureImage = actionCaptureImage {
            actionCaptureImage(img)
        }
    }
}

extension CameraView {
    private enum SessionSetupResult {
        case success
        case notAuthorized
        case configurationFailed
    }
    
    func addSquareWhenTapFocus(point: CGPoint) {
        self.vOverlay.transform = .identity
        self.vOverlay.removeFromSuperview()
        self.addSubview(self.vOverlay)
        self.vOverlay.snp.makeConstraints { make in
            make.width.height.equalTo(100)
            make.centerX.equalTo(point.x)
            make.centerY.equalTo(point.y)
        }
        UIView.animate(withDuration: 0.2) {
            self.vOverlay.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.vOverlay.removeFromSuperview()
            self.vOverlay.transform = .identity
        }
    }
    
    func convertToUIImage(pixelBuffer: CVPixelBuffer) -> UIImage? {
        let image = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext(options: nil)
        guard let cameraImage = context.createCGImage(image, from: image.extent) else { return nil }
        return UIImage(cgImage: cameraImage)
    }
    
    func convertToFlipImage(pixelBuffer: CVPixelBuffer) -> UIImage? {
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        // Tạo CIContext để chuyển đổi CIImage thành CGImage
        let context = CIContext(options: nil)
        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
            // Tạo UIImage từ CGImage
            let uiImage = UIImage(cgImage: cgImage)
            // Đảo chiều ảnh
            let flippedImage = UIImage(cgImage: uiImage.cgImage!, scale: uiImage.scale, orientation: .upMirrored)
            return flippedImage
        }
        return nil
    }
}
