//
//  ChatViewController+Extensios.swift
//  VideoChatApp
//
//  Created by Khanh Vu on 24/06/5 Reiwa.
//

import Foundation
import UIKit
import QuickLook
import MobileCoreServices

extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.listMessages.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.viewModel.listMessages.value[indexPath.row]
        switch item.type {
        case .audio:
            let cell = tableView.dequeueReusableCell(withIdentifier: MessageAudioCell.nibNameClass, for: indexPath) as! MessageAudioCell
            cell.configure(item: item, user: UserModel(), indexPath: indexPath)
            return cell
        case .file:
            let cell = tableView.dequeueReusableCell(withIdentifier: MessageFileCell.nibNameClass, for: indexPath) as! MessageFileCell
//            cell.delegate = self
            cell.configure(item: item, user: UserModel(), indexPath: indexPath)
            cell.actionOpenFile = { [weak self] fileURL in
                guard let self = self else {
                    return
                }
                self.viewModel.downloadFile(from: fileURL)
                    .trackActivity(self.viewModel.loading)
                    .trackError(self.viewModel.errorTracker)
                    .subscribe(onNext: { [weak self] url in
                        self?.viewModel.fileURLPreview = url
                        let qlPreview = QLPreviewController()
                        qlPreview.dataSource = self
                        DispatchQueue.main.async {
                            self?.present(qlPreview, animated: true, completion: nil)
                        }
                    })
                    .disposed(by: self.disposeBag)
            }
            return cell
        case .text:
            let cell = tableView.dequeueReusableCell(withIdentifier: MessageTextCell.nibNameClass, for: indexPath) as! MessageTextCell
            cell.configure(item: item, user: UserModel(), indexPath: indexPath)
            cell.actionTapBubble = { [weak self] in
                self?.tbvListMessage.beginUpdates()
                self?.tbvListMessage.endUpdates()
            }
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: MessagePhotosCell.nibNameClass, for: indexPath) as! MessagePhotosCell
            cell.configure(item: item, user: UserModel(), indexPath: indexPath)
            cell.actionSelectImage = { [weak self] url in
                print(url)
                guard let self = self else {
                    return
                }
                let listDetail = self.viewModel.getListDetailItem()
                let detailVC  = DetailImageViewController()
                detailVC.detailImageViewModel.listImages.accept(listDetail)
                detailVC.detailImageViewModel.currentURL = url
                detailVC.modalPresentationStyle = .fullScreen
                self.present(detailVC, animated: true, completion: nil)
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
         let offsetY = scrollView.contentOffset.y
         let contentHeight = scrollView.contentSize.height
         let tableViewHeight = scrollView.frame.size.height
         
         if offsetY > contentHeight - tableViewHeight && !isLoadingData {
             // User has scrolled to the last row, fetch more data
             self.loadMoreMessages()
             print("fetch more")
         }
     }
}

extension ChatViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return !isRecoding
    }
}

extension ChatViewController: CameraProtocol {
    func didSendImageCaptured(image: UIImage) {
//        self.viewModel.sendImage(images: [image], videos: []) { [weak self] error in
//            guard let error = error else {
//                return
//            }
//            self?.showAlert(title: "Send Image Error!", message: error.localizedDescription)
//        }
    }
}

extension ChatViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
           // Handle the selected file URLs here
        guard let fileURL = urls.first else {
            return
        }
        let fileName = fileURL.lastPathComponent
        let fileSize = fileURL.fileSize()
        self.showAlertWithActionCancel(title: "Remind", message: "You want to send the file \(fileName) to \(self.viewModel.user.value.username ?? "")") {
            print("Hi")
            let media = MediaModel(fileURL: fileURL, fileName: fileName, fileSize: fileSize)
            self.viewModel.handleSendNewMessage(type: .file, media: [media])
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
        return self.viewModel.fileURLPreview! as QLPreviewItem
    }
}
