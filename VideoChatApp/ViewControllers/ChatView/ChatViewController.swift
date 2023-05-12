//
//  ChatViewController.swift
//  ChatApp
//
//  Created by Vu Khanh on 06/03/2023.
//

import UIKit
import IQKeyboardManagerSwift
import RxSwift
import RxCocoa
import RxDataSources
import MobileCoreServices
import QuickLook
import SnapKit

protocol DetailImageProtocol: NSObject {
    func didSelectDetailImage(url: String)
}

class ChatViewController: UIViewController {
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var vBodyScreen: UIView!
    @IBOutlet weak var vTopScreen: UIView!
    @IBOutlet weak var vTypeHere: UIView!
    @IBOutlet weak var txtTypeHere: UITextView!
    @IBOutlet weak var tbvListMessage: UITableView!
    @IBOutlet weak var lbUsername: UILabel!
    @IBOutlet weak var imvAvata: UIImageView!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var lbActive: UILabel!
    @IBOutlet weak var vActive: UIView!
    @IBOutlet weak var vButtonMessage: UIView!
    @IBOutlet weak var heightTxtConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingVButtonMessageConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnLibrary: UIButton!
    @IBOutlet weak var btnArrowRight: UIButton!
    
    private weak var refreshControl: UIRefreshControl!
    var isRecoding = false
    var audioView : AudioView!
    
    let disposeBag = DisposeBag()
    let chatViewModel = ChatViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.chatViewModel.getData()
        self.setUpView()
        self.bindingToViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = false
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = true
        NotificationCenter.default.removeObserver(self)
        self.chatViewModel.setAppInScreenChat(isScreenChat: false)
    }
    
    func setUpView() {
        self.chatViewModel.originalConstraintValue = bottomConstraint.constant
        self.chatViewModel.tbvListMessage = tbvListMessage
        self.chatViewModel.view = self.view
        self.vTopScreen.addConnerRadius(radius: 15)
        self.vTopScreen.addShadow(color: .black, opacity: 0.2, radius: 5, offset: CGSize(width: 1, height: 1))
        self.vActive.addConnerRadius(radius: self.vActive.frame.width/2)
        self.vActive.addBorder(borderWidth: 1, borderColor: .white)
        self.imvAvata.addConnerRadius(radius: self.imvAvata.frame.width/2)
        self.btnSend.isHidden = true
        self.tbvListMessage.register(UINib(nibName: "MessageTableViewCell", bundle: nil), forCellReuseIdentifier: "MessageTableViewCell")
        self.tbvListMessage.register(UINib(nibName: "MessageImageTableViewCell", bundle: nil), forCellReuseIdentifier: "MessageImageTableViewCell")
        self.tbvListMessage.register(UINib(nibName: "MessageVideoTableViewCell", bundle: nil), forCellReuseIdentifier: "MessageVideoTableViewCell")
        self.tbvListMessage.register(UINib(nibName: "MessageFileTableViewCell", bundle: nil), forCellReuseIdentifier: "MessageFileTableViewCell")
        self.tbvListMessage.register(UINib(nibName: "MessageAudioTableViewCell", bundle: nil), forCellReuseIdentifier: "MessageAudioTableViewCell")

        self.txtTypeHere.text = self.chatViewModel.txtChatPlaceHolder
        self.txtTypeHere.textColor = UIColor.lightGray
        self.txtTypeHere.backgroundColor = UIColor(hexString: "#F8F8F8")
        
        self.vTypeHere.backgroundColor = UIColor(hexString: "#F8F8F8")
        self.vTypeHere.addConnerRadius(radius: 15)
        self.vTypeHere.addShadow(color: .gray, opacity: 0.2, radius: 5, offset: CGSize(width: 1, height: 1))
        self.chatViewModel.txtHeightDefault = self.heightTxtConstraint.constant
        self.btnArrowRight.isHidden = true
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshTable), for: .valueChanged)
        tbvListMessage.refreshControl = refreshControl
        
        self.btnSend.layer.cornerRadius = 5
        self.btnSend.layer.masksToBounds = true
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(self.view.endEditing(_:))))
        
        // setUpAudioView
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
    }
    
    

    @objc func keyboardWillChangeFrame(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        let keyboardHeight = view.bounds.height - keyboardFrame.origin.y
        let typeBottom =  vBodyScreen.frame.origin.y + vBodyScreen.frame.height
        let distance = abs(typeBottom -  view.bounds.height)
        self.bottomConstraint.constant = keyboardHeight > 0 ? (keyboardHeight - distance) : self.chatViewModel.originalConstraintValue
        self.chatViewModel.reloadData(tableView: self.tbvListMessage)
        view.layoutIfNeeded()
    }

    func bindingToViewModel() {
        //TableView
        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel> { _, tableView, indexPath, item in
            switch item.type {
            case .image:
                let cell = tableView.dequeueReusableCell(withIdentifier: "MessageImageTableViewCell", for: indexPath) as! MessageImageTableViewCell
                cell.configure(item: item)
                cell.chatVC = self
                return cell
            case .video:
                let cell = tableView.dequeueReusableCell(withIdentifier: "MessageVideoTableViewCell", for: indexPath) as! MessageVideoTableViewCell
                cell.delegate = self
                cell.configure(item: item)
                return cell
            case .audio:
                let cell = tableView.dequeueReusableCell(withIdentifier: "MessageAudioTableViewCell", for: indexPath) as! MessageAudioTableViewCell
                cell.configure(item: item)
                return cell
            case .file:
                let cell = tableView.dequeueReusableCell(withIdentifier: "MessageFileTableViewCell", for: indexPath) as! MessageFileTableViewCell
                cell.delegate = self
                cell.configure(item: item)
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "MessageTableViewCell", for: indexPath) as! MessageTableViewCell
                cell.configure(item: item)
                return cell
            }
        }
        
        self.chatViewModel.listSectionsMessages.bind(to: self.tbvListMessage.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        self.tbvListMessage.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        // subscribe to set content offset when fetch more messages
        self.chatViewModel.newMessagesFetch
            .subscribe(onNext: { [weak self] messages in
                self?.chatViewModel.setContentOffsetOfTableView(tableView: self?.tbvListMessage, messages: messages)
            })
            .disposed(by: disposeBag)
        // bind txtTypeHere
        self.txtTypeHere.rx
            .text
            .orEmpty
            .bind(to: self.chatViewModel.txtTypeHere)
            .disposed(by: disposeBag)
        
        self.txtTypeHere.rx
            .didChange
            .subscribe(onNext: { [weak self] in
                guard let self = self else {
                    return
                }
                let size = CGSize(width: self.txtTypeHere.frame.width, height: .infinity)
                let estimatedSize = self.txtTypeHere.sizeThatFits(size)
                if estimatedSize.height <= 130 {
                    self.heightTxtConstraint.constant = estimatedSize.height + 20
                }
            })
            .disposed(by: disposeBag)
        self.txtTypeHere.rx
            .didBeginEditing
            .subscribe(onNext: { [weak self] in
                if self?.txtTypeHere.text == self?.chatViewModel.txtChatPlaceHolder ?? "" {
                    self?.txtTypeHere.text = ""
                }
                self?.txtTypeHere.textColor = UIColor.black
                self?.btnLibrary.isHidden = true
                self?.btnSend.isHidden = false
                UIView.animate(withDuration: 0.1) {
                    self?.leadingVButtonMessageConstraint.constant = 40 - (10 + (self?.vButtonMessage.frame.width ?? 0))
                    self?.view.layoutIfNeeded()
                } completion: { _ in
                    self?.updateViewTypeTxtWhenEdit(isEdit: true)
                }

            })
            .disposed(by: disposeBag)
        
        self.txtTypeHere.rx
            .didEndEditing
            .subscribe(onNext: { [weak self] in
                if self?.txtTypeHere.text == "" {
                    (self?.txtTypeHere.text = self?.chatViewModel.txtChatPlaceHolder ?? "")
                    self?.txtTypeHere.textColor = UIColor.lightGray
                }
                self?.btnSend.isHidden = true
                self?.btnLibrary.isHidden = false
                self?.heightTxtConstraint.constant = (self?.chatViewModel.txtHeightDefault)!
                UIView.animate(withDuration: 0.3) {
                    self?.leadingVButtonMessageConstraint.constant = 10
                    self?.updateViewTypeTxtWhenEdit(isEdit: false)
                    self?.view.layoutIfNeeded()
                }
            })
            .disposed(by: disposeBag)
        
        // bind lbUsername
        self.chatViewModel.txtUsername
            .subscribe(onNext: { [weak self] text in
                self?.lbUsername.text = text
            })
            .disposed(by: disposeBag)
        
        //bind imvAvata
        self.chatViewModel.roomURL
            .subscribe(onNext: { [weak self] urlStr in
                if let url = URL(string: urlStr) {
                    self?.imvAvata.sd_setImage(with: url, placeholderImage: Constants.Image.defaultAvata)
                } else {
                    self?.imvAvata.image = Constants.Image.defaultAvata
                }
            })
            .disposed(by: disposeBag)
        
        //bind lbActive
        self.chatViewModel.isActive
            .subscribe(onNext: { [weak self] isActive in
                self?.lbActive.text = isActive ? "Active" : "Offline"
                self?.vActive.backgroundColor = isActive ? .green : .gray
            })
            .disposed(by: disposeBag)
    }
    
    @IBAction func btnBackTapped(_ sender: Any) {
        self.addImpactFeedBack()
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSendTapped(_ sender: Any) {
        if self.isRecoding {
            isRecoding = false
            let duration = audioView.duration
            audioView.stopRecording()
            self.updateEventAnimate(vButtonMessage: false, btnSend: true, btnLibrary: false, btnArrowRight: true, audioView: true)
            self.chatViewModel.sendAudio(audioURL: audioView.audioURL, duration: duration) { [weak self] error in
                guard let error = error else {
                    return
                }
                self?.showAlert(title: "Error!", message: error.localizedDescription, completion: nil)
            }
        } else {
            self.txtTypeHere.text = ""
            self.chatViewModel.didTapSendMessage(type: .text) {[weak self] error, _ in
                guard error == nil else {
                    self?.showAlert(title: "Error!", message: error!.localizedDescription)
                    return
                }
            }
        }
    }
    
    @IBAction func btnCameraTapped(_ sender: Any) {
        let filterVC = FilterViewController()
        filterVC.delegate = self
        filterVC.modalPresentationStyle = .fullScreen
        self.present(filterVC, animated: true, completion: nil)
    }
        
    @IBAction func btnAudioTapped(_ sender: Any) {
        self.isRecoding = true
        self.updateEventAnimate(vButtonMessage: true, btnSend: false, btnLibrary: true, btnArrowRight: true, audioView: false)
        audioView.startRecording()
    }
    
    @IBAction func btnLibraryTapped(_ sender: Any) {
        let libraryVC = PhotosViewController()
        libraryVC.delegate = self
        libraryVC.chatVC = self
        self.present(libraryVC, animated: true, completion: nil)
    }
    
    @IBAction func btnFileTapped(_ sender: Any) {
        let documentPicker = UIDocumentPickerViewController(documentTypes: [kUTTypeData as String], in: .import)
        documentPicker.delegate = self // Set the delegate to handle the selected file
        self.present(documentPicker, animated: true, completion: nil)
    }
    
    @IBAction func btnArrowRightTapped(_ sender: Any) {
        self.txtTypeHere.endEditing(true)
        UIView.animate(withDuration: 0.3) {
            self.leadingVButtonMessageConstraint.constant = 10
            self.updateViewTypeTxtWhenEdit(isEdit: false)
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func refreshTable() {
        print("REFRESH")
        self.chatViewModel.fetchMoreMessages {[weak self] error in
            guard let error = error else {
                self?.tbvListMessage.refreshControl?.endRefreshing()
                return
            }
            self?.showAlert(title: "Error!", message: error.localizedDescription, completion: nil)
            self?.tbvListMessage.refreshControl?.endRefreshing()
        }
        tbvListMessage.refreshControl?.endRefreshing()
    }
}

extension ChatViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.chatViewModel.calculateHeightMessage(messageWidth: self.tbvListMessage.frame.width * 0.6, section: indexPath.section, index: indexPath.item)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let vHeader = CustomHeaderView(frame: CGRect(x: 0, y: 0, width: self.tbvListMessage.frame.width, height: 30))
        vHeader.setTitle(title: self.chatViewModel.listSectionsMessages.value[section].header)
        return vHeader
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
}

extension ChatViewController: PhotosDelegate {
    func didTapSendImage(assets: [AssetModel]) {
        self.chatViewModel.getDataAndSent(assets: assets) {[weak self] error in
            guard let error = error else {
                return
            }
            self?.showAlert(title: "Send Image Error!", message: error.localizedDescription)
        }
    }
}

extension ChatViewController: DetailImageProtocol {
    func didSelectDetailImage(url: String) {
        let listDetail = self.chatViewModel.getListDetailItem()
        let detailVC  = DetailImageViewController()
        detailVC.detailImageViewModel.listImages.accept(listDetail)
        detailVC.detailImageViewModel.currentURL = url
        detailVC.modalPresentationStyle = .fullScreen
        self.present(detailVC, animated: true, completion: nil)
    }
}

extension ChatViewController: CameraProtocol {
    func didSendImageCaptured(image: UIImage) {
        self.chatViewModel.sendImage(images: [image], videos: []) { [weak self] error in
            guard let error = error else {
                return
            }
            self?.showAlert(title: "Send Image Error!", message: error.localizedDescription)
        }
    }
}

extension ChatViewController: AudioViewProtocol {
    func didTapBtnDeleteRecording() {
        self.updateEventAnimate(vButtonMessage: false, btnSend: true, btnLibrary: false, btnArrowRight: true, audioView: true)
    }
}

extension ChatViewController: MessageFileProtocol {
    func didSelectOpenFile(fileURL: URL) {
        print("FileURL", fileURL)
        self.chatViewModel.previewFileFromURL(url: fileURL) { [weak self] localURL, error in
            guard let localURL = localURL, error == nil else {
                self?.showAlert(title: "Error!", message: error!.localizedDescription, completion: nil)
                return
            }
            self?.chatViewModel.fileURLPreview = localURL
            let qlPreview = QLPreviewController()
            qlPreview.dataSource = self
            DispatchQueue.main.async {
                self?.present(qlPreview, animated: true, completion: nil)
            }
        }
    }
}

extension ChatViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
           // Handle the selected file URLs here
        guard let fileURL = urls.first else {
            return
        }
        let fileName = fileURL.lastPathComponent
        self.showAlertWithActionCancel(title: "Remind", message: "You want to send the file \(fileName) to \(self.chatViewModel.user2?.username ?? "")") {
            print("Hi")
            self.chatViewModel.sendFile(fileName: fileName,fileURL: fileURL) { error in
                guard let error = error else {
                    return
                }
                self.showAlert(title: "Error!", message: error.localizedDescription, completion: nil)
            }
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        // Handle cancellation
    }
}

extension ChatViewController: QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return self.chatViewModel.fileURLPreview! as QLPreviewItem
    }
}

extension ChatViewController {
    private func updateEventAnimate(vButtonMessage: Bool, btnSend: Bool, btnLibrary: Bool, btnArrowRight: Bool, audioView: Bool) {
        self.vButtonMessage.isHidden = vButtonMessage
        self.btnSend.isHidden = btnSend
        self.btnLibrary.isHidden = btnLibrary
        self.btnArrowRight.isHidden = btnArrowRight
        self.audioView.isHidden = audioView
    }
    
    private func updateViewTypeTxtWhenEdit(isEdit: Bool) {
        self.vButtonMessage.isHidden = isEdit
        self.btnArrowRight.isHidden = !isEdit
    }
}


