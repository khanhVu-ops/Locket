//
//  ChatViewController.swift
//  VideoChatApp
//
//  Created by Khanh Vu on 24/06/5 Reiwa.
//

import UIKit
import MobileCoreServices

protocol DetailImageProtocol: NSObject {
    func didSelectDetailImage(url: String)
}
class ChatViewController: BaseViewController {

    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var vBodyScreen: UIView!
    @IBOutlet weak var vTopScreen: UIView!
    @IBOutlet weak var vTypeHere: UIView!
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
    private weak var refreshControl: UIRefreshControl!
    var isRecoding = false
    var audioView : AudioView!
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func setUpUI() {
        self.vActive.circleClip()
        self.vActive.addBorder(borderWidth: 1, borderColor: .white)
        self.imvAvata.circleClip()
        self.btnBack.setBackgroundImage(Constants.Image.backButton, for: .normal)
        self.tbvListMessage.register(MessageTextCell.self, forCellReuseIdentifier: "MessageTextCell")
        self.tbvListMessage.register(MessageImageTableViewCell.nibClass, forCellReuseIdentifier: MessageImageTableViewCell.nibNameClass)
        self.tbvListMessage.register(MessageVideoTableViewCell.nibClass, forCellReuseIdentifier: MessageVideoTableViewCell.nibNameClass)
        self.tbvListMessage.register(MessageFileTableViewCell.nibClass, forCellReuseIdentifier: MessageFileTableViewCell.nibNameClass)
        self.tbvListMessage.register(MessageAudioTableViewCell.nibClass, forCellReuseIdentifier: MessageAudioTableViewCell.nibNameClass)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshTable), for: .valueChanged)
        tbvListMessage.refreshControl = refreshControl
        
//        self.txtTypeHere.setPlaceholder(self.viewModel.txtChatPlaceHolder)
        self.txtTypeHere.text = self.viewModel.txtChatPlaceHolder
        self.txtTypeHere.textColor = UIColor.lightGray
        self.txtTypeHere.backgroundColor = .white
        self.vBodyScreen.backgroundColor = UIColor(hexString: "#F8F8F8")
        self.vTypeHere.backgroundColor = UIColor(hexString: "#F8F8F8")
        self.viewModel.defaultHeightTv = self.getSizeOfTextView().height
        self.heightTxtConstraint.constant = self.viewModel.defaultHeightTv
        self.btnSend.isHidden = true
        self.btnArrowRight.isHidden = true
        
        audioView = AudioView(height: self.vTypeHere.frame.height-20)
        audioView.isHidden = true
        audioView.delegate = self
        self.vTypeHere.addSubview(audioView)
        audioView.backgroundColor = .clear
        audioView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(10)
            make.leading.equalToSuperview().inset(10)
            make.trailing.equalTo(self.btnSend.snp.leading).offset(-10)
        }
        audioView.addConnerRadius(radius: 10)
        audioView.layoutIfNeeded()
        
        self.addGestureDismissKeyboard()
    }
    
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
                    self?.leadingStvButtonMessageConstraint.constant = 10
                    self?.heightTxtConstraint.constant = self?.viewModel.defaultHeightTv ?? 0
                    self?.updateViewTypeTxtWhenEdit(isEdit: false)
                    
                }
            })
            .disposed(by: disposeBag)
        
        self.btnSend.defaultTap()
            .subscribe(onNext: { [weak self] _ in
                self?.btnSend.dimButton()
                
            })
            .disposed(by: disposeBag)
        
        self.btnLibrary.defaultTap()
            .subscribe(onNext: { [weak self] _ in
                self?.btnLibrary.dimButton()
                let libraryVC = PhotosViewController()
                libraryVC.delegate = self
                libraryVC.chatVC = self
                self?.present(libraryVC, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        self.btnAudio.defaultTap()
            .subscribe(onNext: { [weak self] _ in
                self?.btnAudio.dimButton()
                self?.isRecoding = true
                self?.updateEventAnimate(vButtonMessage: true, btnSend: false, btnLibrary: true, btnArrowRight: true, audioView: false)
                self?.audioView.startRecording()

            })
            .disposed(by: disposeBag)
        
        self.btnCamera.defaultTap()
            .subscribe(onNext: { [weak self] _ in
                self?.btnCamera.dimButton()
                let filterVC = FilterViewController()
                filterVC.delegate = self
                filterVC.modalPresentationStyle = .fullScreen
                self?.present(filterVC, animated: true, completion: nil)
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
    
    override func bindViewModel() {
        // bind txtTypeHere
        self.txtTypeHere.rx
            .text
            .orEmpty
            .bind(to: self.viewModel.txtTypeHere)
            .disposed(by: disposeBag)
        
        self.txtTypeHere.rx
            .didChange
            .subscribe(onNext: { [weak self] in
                guard let self = self else {
                    return
                }
                if self.btnArrowRight.isHidden {
                    UIView.animate(withDuration: 0.1) {
                        self.leadingStvButtonMessageConstraint.constant = 40 - (10 + (self.stvButtonMessage.frame.width))
                        self.view.layoutIfNeeded()
                    } completion: { _ in
                        self.updateViewTypeTxtWhenEdit(isEdit: true)
                    }
                }
                let newSize = self.getSizeOfTextView()
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
                if self.txtTypeHere.text == self.viewModel.txtChatPlaceHolder {
                    self.txtTypeHere.text = ""
                } else {
                    self.heightTxtConstraint.constant = self.viewModel.currentHeightTv
                }
                self.txtTypeHere.textColor = UIColor.black
                self.updateWhenInputText(isEndEdit: false)

            })
            .disposed(by: disposeBag)

        self.txtTypeHere.rx
            .didEndEditing
            .subscribe(onNext: { [weak self] in
                guard let self = self else {
                    return
                }
                if self.txtTypeHere.text == "" {
                    self.txtTypeHere.text = self.viewModel.txtChatPlaceHolder
                    self.txtTypeHere.textColor = UIColor.lightGray
                }
                self.heightTxtConstraint.constant = self.viewModel.defaultHeightTv
                self.updateWhenInputText(isEndEdit: true)
            })
            .disposed(by: disposeBag)
    }
    
    override func bindEvent() {
        self.keyboardTrigger.skip(1).asDriverComplete()
            .drive(onNext: { [weak self] keyboard in
                guard let self = self else { return }
                print(keyboard.height)
                self.bottomConstraint.constant = keyboard.height > 0 ? (keyboard.height) : 20
                UIView.animate(withDuration: keyboard.duration) {
                    self.view.layoutIfNeeded()
                }
            }).disposed(by: disposeBag)
    }
    
    @objc func refreshTable() {
        print("REFRESH")
//        self.chatViewModel.fetchMoreMessages {[weak self] error in
//            guard let error = error else {
//                self?.tbvListMessage.refreshControl?.endRefreshing()
//                return
//            }
//            self?.showAlert(title: "Error!", message: error.localizedDescription, completion: nil)
//            self?.tbvListMessage.refreshControl?.endRefreshing()
//        }
//        tbvListMessage.refreshControl?.endRefreshing()
    }
    
    func getSizeOfTextView() -> CGSize {
        let fixedWidth = txtTypeHere.frame.size.width
        let newSize = txtTypeHere.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        return newSize
    }
}

extension ChatViewController {
    func updateEventAnimate(vButtonMessage: Bool, btnSend: Bool, btnLibrary: Bool, btnArrowRight: Bool, audioView: Bool) {
        self.stvButtonMessage.isHidden = vButtonMessage
        self.btnSend.isHidden = btnSend
        self.btnLibrary.isHidden = btnLibrary
        self.btnArrowRight.isHidden = btnArrowRight
        self.audioView.isHidden = audioView
    }
    
    func updateViewTypeTxtWhenEdit(isEdit: Bool) {
        self.stvButtonMessage.isHidden = isEdit
        self.btnArrowRight.isHidden = !isEdit
        self.view.layoutIfNeeded()
    }
    
    func updateWhenInputText(isEndEdit: Bool) {
        self.btnSend.isHidden = isEndEdit
        self.btnLibrary.isHidden = !isEndEdit
        UIView.animate(withDuration: 0.3) {
            self.leadingStvButtonMessageConstraint.constant = isEndEdit ? 10 : 40 - (10 + (self.stvButtonMessage.frame.width))
            self.updateViewTypeTxtWhenEdit(isEdit: !isEndEdit)
            self.view.layoutIfNeeded()
        }

    }
}
