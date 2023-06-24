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
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.viewModel.listMessages[indexPath.row]
        switch item.type {
        case .image:
            let cell = tableView.dequeueReusableCell(withIdentifier: MessageImageTableViewCell.nibNameClass, for: indexPath) as! MessageImageTableViewCell
            cell.configure(item: item)
            cell.chatVC = self
            return cell
        case .video:
            let cell = tableView.dequeueReusableCell(withIdentifier: MessageVideoTableViewCell.nibNameClass, for: indexPath) as! MessageVideoTableViewCell
            cell.delegate = self
            cell.configure(item: item)
            return cell
        case .audio:
            let cell = tableView.dequeueReusableCell(withIdentifier: MessageVideoTableViewCell.nibNameClass, for: indexPath) as! MessageAudioTableViewCell
            cell.configure(item: item)
            return cell
        case .file:
            let cell = tableView.dequeueReusableCell(withIdentifier: MessageVideoTableViewCell.nibNameClass, for: indexPath) as! MessageFileTableViewCell
            cell.delegate = self
            cell.configure(item: item)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: MessageVideoTableViewCell.nibNameClass, for: indexPath) as! MessageTableViewCell
            cell.configure(item: item)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.viewModel.calculateHeightMessage(messageWidth: self.tbvListMessage.frame.width * 0.6, section: indexPath.section, index: indexPath.item)
    }
}

extension ChatViewController: PhotosDelegate {
    func didTapSendImage(assets: [AssetModel]) {
        self.viewModel.getDataAndSent(assets: assets) {[weak self] error in
            guard let error = error else {
                return
            }
            self?.showAlert(title: "Send Image Error!", message: error.localizedDescription)
        }
    }
}

extension ChatViewController: DetailImageProtocol {
    func didSelectDetailImage(url: String) {
        let listDetail = self.viewModel.getListDetailItem()
        let detailVC  = DetailImageViewController()
        detailVC.detailImageViewModel.listImages.accept(listDetail)
        detailVC.detailImageViewModel.currentURL = url
        detailVC.modalPresentationStyle = .fullScreen
        self.present(detailVC, animated: true, completion: nil)
    }
}

extension ChatViewController: CameraProtocol {
    func didSendImageCaptured(image: UIImage) {
        self.viewModel.sendImage(images: [image], videos: []) { [weak self] error in
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
        self.viewModel.previewFileFromURL(url: fileURL) { [weak self] localURL, error in
            guard let localURL = localURL, error == nil else {
                self?.showAlert(title: "Error!", message: error!.localizedDescription, completion: nil)
                return
            }
            self?.viewModel.fileURLPreview = localURL
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
        self.showAlertWithActionCancel(title: "Remind", message: "You want to send the file \(fileName) to \(self.viewModel.user2?.username ?? "")") {
            print("Hi")
            self.viewModel.sendFile(fileName: fileName,fileURL: fileURL) { error in
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
        return self.viewModel.fileURLPreview! as QLPreviewItem
    }
}
