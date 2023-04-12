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
    @IBOutlet weak var heightTxtConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnLibrary: UIButton!
    
    private weak var refreshControl: UIRefreshControl!
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
    }
    
    func setUpView() {
        self.chatViewModel.originalConstraintValue = bottomConstraint.constant
        self.chatViewModel.tbvListMessage = tbvListMessage
        self.vTopScreen.addConnerRadius(radius: 15)
        self.vTopScreen.addShadow(color: .black, opacity: 0.2, radius: 5, offset: CGSize(width: 1, height: 1))
        self.vActive.addConnerRadius(radius: self.vActive.frame.width/2)
        self.vActive.addBorder(borderWidth: 1, borderColor: .white)
        self.imvAvata.addConnerRadius(radius: self.imvAvata.frame.width/2)
        self.btnSend.isHidden = true
        
        self.tbvListMessage.register(UINib(nibName: "MessageTableViewCell", bundle: nil), forCellReuseIdentifier: "MessageTableViewCell")
        self.tbvListMessage.register(UINib(nibName: "MessageImageTableViewCell", bundle: nil), forCellReuseIdentifier: "MessageImageTableViewCell")
        self.tbvListMessage.register(UINib(nibName: "MessageVideoTableViewCell", bundle: nil), forCellReuseIdentifier: "MessageVideoTableViewCell")
        
        self.txtTypeHere.text = "Type here"
        self.txtTypeHere.textColor = UIColor.lightGray
        self.txtTypeHere.backgroundColor = UIColor(hexString: "#F8F8F8")
        
        self.vTypeHere.backgroundColor = UIColor(hexString: "#F8F8F8")
        self.vTypeHere.addConnerRadius(radius: 15)
        self.vTypeHere.addShadow(color: .gray, opacity: 0.2, radius: 5, offset: CGSize(width: 1, height: 1))
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshTable), for: .valueChanged)
        tbvListMessage.refreshControl = refreshControl
        
        self.btnSend.layer.cornerRadius = 5
        self.btnSend.layer.masksToBounds = true
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(self.view.endEditing(_:))))
    }
    
    

    @objc func keyboardWillChangeFrame(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        let keyboardHeight = view.bounds.height - keyboardFrame.origin.y
        let typeBottom =  vBodyScreen.frame.origin.y + vBodyScreen.frame.height
        let distance = abs(typeBottom -  view.bounds.height)
        self.bottomConstraint.constant = keyboardHeight > 0 ? (keyboardHeight - distance) : self.chatViewModel.originalConstraintValue
//        DispatchQueue.main.async { [weak self] in
//            self?.tbvListMessage.reloadData()
//            self?.chatViewModel.scrollToBottom(tableView: self?.tbvListMessage)
//        }
        self.chatViewModel.reloadData(tableView: self.tbvListMessage)
        view.layoutIfNeeded()
    }

    func bindingToViewModel() {
        //bind tbvMessages
        self.chatViewModel.listMessages
            .bind(to: self.tbvListMessage.rx.items) { [weak self] tableView, index, element -> UITableViewCell in
                
                if element.type == .image {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "MessageImageTableViewCell", for: IndexPath(row: index, section: 0)) as! MessageImageTableViewCell
                    cell.configure(item: element)
                    cell.chatVC = self
                    return cell
                } else if element.type == .video {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "MessageVideoTableViewCell", for: IndexPath(row: index, section: 0)) as! MessageVideoTableViewCell
                    cell.delegate = self
                    cell.configure(item: element)
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "MessageTableViewCell", for: IndexPath(row: index, section: 0)) as! MessageTableViewCell
                    cell.configure(item: element)
                    return cell
                }
            }
            .disposed(by: disposeBag)
        
        self.tbvListMessage.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
//        self.chatViewModel.listMessages
//            .subscribe(onNext: {[weak self] _ in
////                self?.chatViewModel.reloadData(tableView: (self?.tbvListMessage)!)
//            })
//            .disposed(by: disposeBag)
        
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
                self?.txtTypeHere.text = nil
                self?.txtTypeHere.textColor = UIColor.black
                self?.btnLibrary.isHidden = true
                self?.btnSend.isHidden = false
            })
            .disposed(by: disposeBag)
        
        self.txtTypeHere.rx
            .didEndEditing
            .subscribe(onNext: { [weak self] in
                self?.txtTypeHere.text = "Type here ..."
                self?.txtTypeHere.textColor = UIColor.lightGray
                self?.btnSend.isHidden = true
                self?.btnLibrary.isHidden = false
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
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSendTapped(_ sender: Any) {
        self.txtTypeHere.text = ""
        self.chatViewModel.didTapSendMessage(type: .text) {[weak self] error, _ in
            guard error == nil else {
                self?.showAlert(title: "Error!", message: error!.localizedDescription)
                return
            }
        }
    }
    
    @IBAction func btnCameraTapped(_ sender: Any) {
        let filterVC = FilterViewController()
        filterVC.delegate = self
        filterVC.modalPresentationStyle = .fullScreen
        self.present(filterVC, animated: true, completion: nil)
//        self.navigationController?.pushViewController(filterVC, animated: true)
    }
    @IBAction func btnLibraryTapped(_ sender: Any) {
        let libraryVC = PhotosViewController()
        libraryVC.delegate = self
        libraryVC.chatVC = self
        self.present(libraryVC, animated: true, completion: nil)
//        self.present(imagePicker, animated: true)
    }
    
    @IBAction func btnVideoCall(_ sender: Any) {
        let detailVC = DetailImageViewController()
//        detailVC.modalPresentationStyle = .fullScreen
//        self.present(detailVC, animated: true, completion: nil)
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    @IBAction func btnAudioCall(_ sender: Any) {
        
    }
    
    @objc func refreshTable() {
        print("REFRESH")
        self.chatViewModel.loadingMessage {[weak self] error in
            guard let error = error else {
                self?.tbvListMessage.refreshControl?.endRefreshing()
                return
            }
            self?.tbvListMessage.refreshControl?.endRefreshing()
//            self?.chatViewModel.setContentOffsetOfTableView(tableView: self?.tbvListMessage)
        }
        tbvListMessage.refreshControl?.endRefreshing()
    }
}

extension ChatViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        self.chatViewModel.calculateHeightMessage(messageWidth: self.tbvListMessage.frame.width * 0.6, index: indexPath.item)
    }
//
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//            if scrollView.contentOffset.y < 0 {
//                // Hiển thị indicator khi người dùng cuộn lên đầu
//                tbvListMessage.refreshControl?.beginRefreshing()
//
//                // Gọi hàm thực hiện tác vụ bạn muốn khi người dùng cuộn lên đầu
//                refreshTable()
//            }
//        }
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


