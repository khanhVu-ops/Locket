//
//  ChatViewController.swift
//  VideoChatApp
//
//  Created by Khanh Vu on 24/06/5 Reiwa.
//

import UIKit
import MobileCoreServices

class ChatViewController: BaseViewController {

    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var vBodyScreen: UIView!
    @IBOutlet weak var vTopScreen: UIView!
    @IBOutlet weak var vTypeHere: UIView!
    @IBOutlet weak var lbPlaceHolder: UILabel!
    @IBOutlet weak var vBorderTxt: UIView!
    @IBOutlet weak var txtTypeHere: UITextView!
    @IBOutlet weak var tbvListMessage: UITableView!
    @IBOutlet weak var lbUsername: UILabel!
    @IBOutlet weak var imvAvata: UIImageView!
    @IBOutlet weak var lbActive: UILabel!
    @IBOutlet weak var vActive: UIView!
    @IBOutlet weak var stvButtonMessage: UIStackView!
    @IBOutlet weak var heightTxtConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingStvButtonMessageConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnLibrary: UIButton!
    @IBOutlet weak var btnCamera: UIButton!
    @IBOutlet weak var btnFile: UIButton!
    @IBOutlet weak var btnAudio: UIButton!
    @IBOutlet weak var btnArrowRight: UIButton!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    let viewModel = ChatViewModel()
//    private weak var refreshControl: UIRefreshControl!
    var isRecoding = false
    var audioView : AudioView!
    var isLoadingData = false

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    deinit {
        self.viewModel.removeFileDownload()
        FirebaseService.shared.updateStatusChating(isChating: false)
    }
//MARK: SetupUI
    override func setUpUI() {
        self.tbvListMessage.transform = CGAffineTransform.init(rotationAngle: (-(CGFloat)(Double.pi)))
        self.tbvListMessage.contentInset.top = 10
        self.vActive.circleClip()
        self.vActive.addBorder(borderWidth: 1, borderColor: .white)
        self.imvAvata.circleClip()
        self.tbvListMessage.register(MessageTextCell.self, forCellReuseIdentifier: MessageTextCell.nibNameClass)
        self.tbvListMessage.register(MessagePhotosCell.self, forCellReuseIdentifier: MessagePhotosCell.nibNameClass)
        self.tbvListMessage.register(MessageFileCell.self, forCellReuseIdentifier: MessageFileCell.nibNameClass)
        self.tbvListMessage.register(MessageAudioCell.self, forCellReuseIdentifier: MessageAudioCell.nibNameClass)
        self.tbvListMessage.backgroundColor = UIColor(hexString: "#F9F9F9")
        self.tbvListMessage.dataSource = self
        self.tbvListMessage.delegate = self
        
        self.btnSend.isHidden = true
        self.btnArrowRight.isHidden = true
        self.btnFile.tintColor = RCValues.shared.color(forKey: .appPrimaryColor)
        self.btnCamera.tintColor = RCValues.shared.color(forKey: .appPrimaryColor)
        self.btnAudio.tintColor = RCValues.shared.color(forKey: .appPrimaryColor)
        self.btnLibrary.tintColor = RCValues.shared.color(forKey: .appPrimaryColor)
        self.btnArrowRight.tintColor = RCValues.shared.color(forKey: .appPrimaryColor)
        self.vBorderTxt.addConnerRadius(radius: 15)
        self.txtTypeHere.backgroundColor = .white
        self.txtTypeHere.delegate = self
        self.vBodyScreen.backgroundColor = RCValues.shared.color(forKey: .inputTxtChatColor)
        self.vTypeHere.backgroundColor = RCValues.shared.color(forKey: .inputTxtChatColor)
        self.viewModel.defaultHeightTv = self.txtTypeHere.getSize().height
        self.viewModel.currentHeightTv = self.viewModel.defaultHeightTv
        self.heightTxtConstraint.constant = self.viewModel.defaultHeightTv
        self.txtTypeHere.text = ""
        let txtGesture = UITapGestureRecognizer(target: self, action: #selector(tapTxtTypeHere))
        self.txtTypeHere.addGestureRecognizer(txtGesture)
        
        self.audioView = AudioView(height: self.vTypeHere.frame.height-20)
        self.vTypeHere.addSubview(audioView)
        self.audioView.isHidden = true
        self.audioView.actionCancel = { [weak self] in
            self?.updateUIWhenRecording(isRecording: false)
        }
        self.audioView.backgroundColor = .clear
        self.audioView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(10)
            make.leading.equalToSuperview().inset(10)
            make.trailing.equalTo(self.btnSend.snp.leading).offset(-10)
        }
        self.audioView.addConnerRadius(radius: 10)
        self.audioView.layoutIfNeeded()
        
        self.addGestureDismissKeyboard(view: self.tbvListMessage)
    }
    
    //MARK: Setup Tap
    override func setUpTap() {
        self.btnBack.defaultTap()
            .subscribe(onNext: { [weak self] _ in
                self?.btnBack.dimButton()
                self?.pop()
        
            })
            .disposed(by: disposeBag)
        
        self.btnArrowRight.defaultTap()
            .subscribe(onNext: { [weak self] _ in
                UIView.animate(withDuration: 0.3) {
                    self?.heightTxtConstraint.constant = self?.viewModel.defaultHeightTv ?? 0
                    self?.updateWhenInputText(isEdit: false)
                }
            })
            .disposed(by: disposeBag)
        
        self.btnSend.defaultTap()
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else {
                    return
                }
                if self.isRecoding {
                    let duration = self.audioView.duration
                    self.audioView.stopRecording()
                    self.updateUIWhenRecording(isRecording: false)
                    let media = MediaModel(audioURL: self.audioView.audioURL, duration: duration)
                    self.viewModel.handleSendNewMessage(type: .audio, media: [media])
                    //send firebase
                    
                } else {
                    if self.txtTypeHere.text.trimSpaceAndNewLine() == "" {
                        return
                    }
                    self.btnSend.dimButton()
                    self.viewModel.txtMessage = self.txtTypeHere.text
                    self.txtTypeHere.text = ""
                    self.heightTxtConstraint.constant = self.viewModel.defaultHeightTv
                    self.viewModel.handleSendNewMessage(type: .text, media: [])
                }
            })
            .disposed(by: disposeBag)
        
        self.btnLibrary.defaultTap()
            .subscribe(onNext: { [weak self] _ in
                self?.btnLibrary.dimButton()
                let libraryVC = PhotosViewController()
                libraryVC.actionSendAsset = { [weak self] asset in
                    self?.viewModel.handleSendAsset(medias: asset)
                }
                self?.present(libraryVC, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        self.btnAudio.defaultTap()
            .subscribe(onNext: { [weak self] _ in
                self?.btnAudio.dimButton()
                self?.viewModel.checkPermissionAudio(completion: { [weak self] granted in
                    if granted {
                        self?.updateUIWhenRecording(isRecording: true)
                        self?.audioView.startRecording()
                    } else {
                        self?.showAlertOpenSettingAudio()
                    }
                })
            })
            .disposed(by: disposeBag)
        
        self.btnCamera.defaultTap()
            .subscribe(onNext: { [weak self] _ in
//                self?.btnCamera.dimButton()
                let filterVC = FilterViewController()
                filterVC.modalPresentationStyle = .fullScreen
                filterVC.actionSendImage = { [weak self] image in
                    let media = MediaModel(image: image)
                    self?.viewModel.handleSendNewMessage(type: .image, media: [media])
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self?.present(filterVC, animated: true, completion: nil)
                }
                
                
            })
            .disposed(by: disposeBag)
        
        self.btnFile.defaultTap()
            .subscribe(onNext: { [weak self] _ in
                self?.btnFile.dimButton()
                let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypeData as String], in: .import)
                documentPicker.delegate = self // Set the delegate to handle the selected file
                self?.present(documentPicker, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
    
    //MARK: bind ViewModel
    override func bindViewModel() {
        // get data
        self.viewModel.getConversationID()
        self.viewModel.getInfoUser()
        
        self.viewModel.listMessages
            .subscribe(onNext: { [weak self] messages in
                UIView.performWithoutAnimation { [weak self] in
                    self?.tbvListMessage.reloadData()
                }
            })
            .disposed(by: disposeBag)
        
        self.viewModel.conversationID
            .subscribe(onNext: { [weak self] conversaionID in
                guard let self = self else {
                    return
                }
                self.viewModel.getListMessages(conversationID: conversaionID)
                self.viewModel.updateWhenLoadChat(conversationID: conversaionID)
            })
            .disposed(by: disposeBag)
        
//        self.viewModel.newMessageID
//            .subscribe(onNext: { [weak self] messageID in
//                self?.viewModel.updateWhenSentMessage(messageID: messageID, status: .sent)
//            })
//            .disposed(by: disposeBag)
//
        AppObserver.shared.messageSentObservable()
            .subscribe(onNext: { [weak self] messageID in
                self?.viewModel.updateWhenSentMessage(messageID: messageID, status: .sent)
            })
            .disposed(by: disposeBag)
        self.viewModel.user
            .subscribe(onNext: { [weak self] user in
                self?.lbUsername.text = user.username
                self?.lbActive.text = user.isActive == true ? "Online" : "Offline"
                self?.vActive.backgroundColor = user.isActive == true ? .green : .gray
                self?.imvAvata.setImage(urlString: user.avataURL ?? "", placeHolder: Constants.Image.defaultAvataImage)
            })
            .disposed(by: disposeBag)
        
        
        // bind textview
        self.txtTypeHere.rx
            .didChange
            .subscribe(onNext: { [weak self] in
                guard let self = self else {
                    return
                }
                if self.btnArrowRight.isHidden {
                    self.updateWhenInputText(isEdit: true)
                }
                let newSize = self.txtTypeHere.getSize()
                if newSize.height < self.viewModel.maxheightTv {
                    self.txtTypeHere.isScrollEnabled = false
                    self.heightTxtConstraint.constant = newSize.height
                    self.viewModel.currentHeightTv = newSize.height
                } else {
                    self.txtTypeHere.isScrollEnabled = true
                }
            })
            .disposed(by: disposeBag)
        
        self.txtTypeHere.rx
            .didBeginEditing
            .subscribe(onNext: { [weak self] in
                guard let self = self else {
                    return
                }
                self.heightTxtConstraint.constant = self.viewModel.currentHeightTv
                self.updateWhenInputText(isEdit: true)

            })
            .disposed(by: disposeBag)

        self.txtTypeHere.rx
            .didEndEditing
            .subscribe(onNext: { [weak self] in
                guard let self = self else {
                    return
                }
                self.heightTxtConstraint.constant = self.viewModel.defaultHeightTv
                self.updateWhenInputText(isEdit: false)
            })
            .disposed(by: disposeBag)
    
        self.txtTypeHere.rx.text.orEmpty
            .map({
                $0.isEmpty
            })
            .subscribe(onNext: { [weak self] isEnable in
                self?.lbPlaceHolder.isHidden = !isEnable
                self?.btnSend.isHidden = isEnable
                self?.btnLibrary.isHidden = !isEnable
            })
            .disposed(by: disposeBag)

    }
    
    override func bindEvent() {
        self.trackShowToastError(self.viewModel)
        self.keyboardTrigger.skip(1).asDriverComplete()
            .drive(onNext: { [weak self] keyboard in
                guard let self = self else { return }
                self.bottomConstraint.constant = keyboard.height > 0 ? (keyboard.height) : 20
                UIView.animate(withDuration: keyboard.duration) { [weak self] in
                    self?.view.layoutIfNeeded()
                }
            }).disposed(by: disposeBag)
    }
    
    @objc func tapTxtTypeHere() {
        self.txtTypeHere.becomeFirstResponder()
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else {
                return
            }
            self.heightTxtConstraint.constant = self.viewModel.currentHeightTv
            self.updateWhenInputText(isEdit: true)
            self.view.layoutIfNeeded()
        }
    }
}

extension ChatViewController {

    func updateUIWhenRecording(isRecording: Bool) {
        self.isRecoding = isRecording
        self.stvButtonMessage.isHidden = isRecording
        self.audioView.isHidden = !isRecording
        self.btnSend.isHidden = !isRecording
        self.btnLibrary.isHidden = isRecording
    }
    
    func updateWhenInputText(isEdit: Bool) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else {
                return
            }
            self.leadingStvButtonMessageConstraint.constant = !isEdit ? 10 : 35 - (10 + (self.stvButtonMessage.frame.width))
            self.stvButtonMessage.isHidden = isEdit
            self.btnArrowRight.isHidden = !isEdit
            self.view.layoutIfNeeded()
        }
    }
    
    private func scrollFirstRow(_ animated: Bool = false) {
        DispatchQueue.main.async { [weak self] in
            self?.tbvListMessage.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: animated)
        }
    }
    
    func createActivityIndicator() -> UIView {
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.startAnimating()
        activityIndicator.frame = CGRect(x: 0, y: 0, width: tbvListMessage.bounds.width, height: 40)
        
        let containerView = UIView(frame: CGRect(x: 0, y: 0, width: tbvListMessage.bounds.width, height: 40))
        containerView.addSubview(activityIndicator)
        
        return containerView
    }
    
    func loadMoreMessages() {
        self.isLoadingData = true
        tbvListMessage.tableFooterView = createActivityIndicator()
        self.viewModel.loadMoreMessages()
            .subscribe(onNext: { [weak self] new in
                guard let self = self else {
                    return
                }
                if new.count > 0 {
                    self.isLoadingData = false
                    self.tbvListMessage.tableFooterView = nil
                    var old = self.viewModel.listMessages.value
                    old.append(contentsOf: new)
                    self.viewModel.listMessages.accept(self.viewModel.prehandleMessages(messages: old))
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.isLoadingData = false
                        self.tbvListMessage.tableFooterView = nil
                    }
                }
                
            })
            .disposed(by: disposeBag)
    }
}
