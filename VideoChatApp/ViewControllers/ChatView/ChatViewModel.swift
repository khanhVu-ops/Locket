//
//  ChatViewModel.swift
//  ChatApp
//
//  Created by Vu Khanh on 09/03/2023.
//

import Foundation
import RxSwift
import RxCocoa
import FirebaseFirestore
import FirebaseStorage
import Photos
import UIKit
import QuickLook
class ChatViewModel: BaseViewModel {
    let txtChatPlaceHolder = "Type here ..."
    var listMessages = [MessageModel]()
    var listSectionsMessages = BehaviorRelay<[SectionModel]>(value: [])
    var uid = UserDefaultManager.shared.getID()
    var txtTypeHere = BehaviorRelay<String>(value: "")
    var roomRef: DocumentReference?
    var chatRoom: ChatModel?
    var user2: UserModel?
    var txtUsername = BehaviorRelay<String>(value: "Username")
    var roomURL = BehaviorRelay<String>(value: "")
    var isActive = BehaviorRelay<Bool>(value: false)
    var uid2: String?
    var imageSentRelay = PublishRelay<UIImage>()
    var lastDocument: QueryDocumentSnapshot?
    var newMessagesFetch = PublishRelay<[MessageModel]>()
    var tbvListMessage: UITableView?
    var fileURLPreview: URL?
    // textview
    var currentHeightTv: CGFloat = 0
    var defaultHeightTv: CGFloat = 0
    var maxheightTv: CGFloat = 120
    
    
    func getListMessage() {
        
    }
    
    func getData() {
        if let uid2 = uid2 {
            self.getInfoUsers2WithUID(uid2: uid2)
            FirebaseManager.shared.getDocumentReferenceWithUserID(userId2: uid2) { [weak self] doc, error in
                guard let doc = doc, error == nil else {
                    return
                }
                self?.roomRef = doc
                self?.setAppInScreenChat(isScreenChat: true)
                self?.getMessages(completion: { error in
                    print(error?.localizedDescription)
                })
                
            }
        }
        
    }
    
    func getInfoUsers2WithUID(uid2: String) {
        FirebaseManager.shared.getUsers { [weak self] users, error in
            guard let users = users, error == nil else {
                return
            }
            for user in users {
                if user.id == uid2 {
                    self?.user2 = user
                    self?.txtUsername.accept(user.username ?? "Username")
                    self?.roomURL.accept(user.avataURL ?? "")
                    self?.isActive.accept(user.isActive ?? false)
                    break
                }
            }
        }
    }
    
    func getMessages(completion: @escaping(Error?)->Void) {
        guard let roomRef = roomRef else {
            return
        }
        FirebaseManager.shared.getMessages(docRef: roomRef) {[weak self] messages, lastDoc, error in
            guard let messages = messages, error == nil else {
                print(error!.localizedDescription)
                completion(error)
                return
            }
            self?.lastDocument = lastDoc
            self?.listMessages = messages
            self?.handleSortMessagesByDate(messages: messages)
            guard let tbvListMessage = self?.tbvListMessage else {
                return
            }
            self?.reloadData(tableView: tbvListMessage)
            completion(nil)
        }
    }
    
    private func handleSortMessagesByDate(messages: [MessageModel]) {
        var uniqueDates: [Date] = []
        for message in messages {
            let date = message.created!.dateValue()
            if !uniqueDates.contains(where: { Calendar.current.isDate($0, inSameDayAs: date) }) {
                uniqueDates.append(date)
            }
        }
        var resultMessages = [[MessageModel]]()
        for date in uniqueDates {
            let dateTimestamps = messages.filter { Calendar.current.isDate($0.created!.dateValue(), inSameDayAs: date) }
            resultMessages.append(dateTimestamps)
        }
        var sections = [SectionModel]()
        for (index, value) in uniqueDates.enumerated() {
            let section = SectionModel(header: value.convertDateToHeaderString(), items: resultMessages[index])
            sections.append(section)
        }
        self.listSectionsMessages.accept(sections)
    }
    
    // fetch more 20 messages
    func fetchMoreMessages(completion: @escaping(Error?) -> Void) {
        guard let roomRef = roomRef, let lastDocument = lastDocument else {
            return
        }
        FirebaseManager.shared.getMessagesWithLastDoc(docRef: roomRef, lastDocument: lastDocument, limitQuery: 20) { [weak self] messages, lastDoc, error in
            guard let messages = messages, error == nil else {
                completion(error)
                return
            }
            var newMess = messages
            newMess.append(contentsOf: self!.listMessages)
            self?.newMessagesFetch.accept(messages)
            self?.listMessages = newMess
            self?.handleSortMessagesByDate(messages: newMess)
            self?.lastDocument = lastDoc
            completion(nil)
        }
    }
    
    func didTapSendMessage(type: MessageType, images: [String]? = nil, ratio: Double? = nil, videoURL: String? = nil, thumbVideo: String? = nil, audioURL: String? = nil, duration: Double? = nil, fileName: String? = nil, fileURL: String? = nil, completion: @escaping(Error?, DocumentReference?)->Void) {
        guard let uid = uid else {
            return
        }
        var content: MessageModel?
        var bodyNotification = ""
        switch type {
        case .text:
            guard self.txtTypeHere.value != "" else {
                completion(nil, nil)
                return
            }
            let textMessage = self.txtTypeHere.value.trimmingCharacters(in: .whitespacesAndNewlines)
            content = MessageModel(type: .text, message: textMessage, senderID: uid, created: Timestamp(date: Date()))
            bodyNotification = textMessage
            
        case .image:
            guard let images = images, let ratio = ratio else {
                return
            }
            content = MessageModel(type: .image, imageURL: images, ratioImage: ratio, senderID: uid, created: Timestamp(date: Date()))
            bodyNotification = "Send you \(images.count) picture."
        case .video:
            guard let videoURL = videoURL, let duration = duration else {
                return
            }
            content = MessageModel(type: .video, ratioImage: ratio, thumbVideo: thumbVideo, videoURL: videoURL, duration: duration, senderID: uid, created: Timestamp(date: Date()))
            bodyNotification = "Send you a video."
        case .file:
            guard let fileName = fileName else {
                return
            }
            content = MessageModel(type: .file, fileName: fileName, senderID: uid, created: Timestamp(date: Date()))
            bodyNotification = "Send you a file."
        case .audio:
            guard let audioURL = audioURL else {
                return
            }
            content = MessageModel(type: .audio, audioURL: audioURL, duration: duration, senderID: uid, created: Timestamp(date: Date()))
            bodyNotification = "Send you a audio."
        }
        
        if let roomRef = roomRef {
            self.addNewMessage(content: content!, roomRef: roomRef) { err, messRef in
                guard let messRef = messRef, err == nil else {
                    completion(err, nil)
                    return
                }
                if self.user2?.isChating == false {
                    FirebaseManager.shared.updateUnreadMessage(id: self.uid2!, clearUnread: false, roomRef: roomRef)
//                    APIService.shared.pushNotificationMessage(fcmToken: self.user2?.fcmToken, uid: self.uid, title: self.user!.username, body: bodyNotification, badge: (self.user2?.totalBadge ?? 0) + 1)
                }
                completion(err, messRef)
            }
        } else {
            guard let user2 = self.user2 else {
                completion(nil, nil)
                return
            }
            let roomData = ChatModel(users: [uid, user2.id!], unreadArray: [0, 0])
            self.createNewRoom(newRoom: roomData, content: content!) { roomRef, messRef, error in
                
                guard let roomRef = roomRef, let messRef = messRef, error == nil else {
                    completion(error, nil)
                    return
                }
                
                if user2.isChating == false {
                    FirebaseManager.shared.updateUnreadMessage(id: self.uid2!, clearUnread: false, roomRef: roomRef)
//                    APIService.shared.pushNotificationMessage(fcmToken: self.user2?.fcmToken, uid: self.uid, title: self.user!.username, body: bodyNotification, badge: (self.user2?.totalBadge ?? 0) + 1)
                    
                }
                completion(nil, messRef)
            }
        }
    }
    
    func createNewRoom(newRoom: ChatModel, content: MessageModel, completion: @escaping(DocumentReference?, DocumentReference?, Error?)->Void) {
        FirebaseManager.shared.creatNewChat(newRoom: newRoom, content: content, completion: {[weak self] roomRef, messRef, error in
            guard let roomRef = roomRef, let messRef = messRef, error == nil else {
                completion(nil ,nil ,error)
                return
            }
            self?.roomRef = roomRef
            self?.getMessages(completion: { err in
                print("zo")
                completion(roomRef, messRef, err)
            })
        })
    }
    
    func addNewMessage(content: MessageModel, roomRef: DocumentReference, completion: @escaping(Error?, DocumentReference?)->Void) {
        FirebaseManager.shared.addNewMessage(content: content, docRef: roomRef) { error, messRef in
            guard error == nil else {
                completion(error, nil)
                return
            }
            completion(nil, messRef)
        }
    }
    
    func sendImage(images: [UIImage], videos: [AssetModel], completion: @escaping(Error?)->Void) {
        let ratio = images[0].size.height/images[0].size.width
        self.didTapSendMessage(type: .image, images: [String](repeating: "Loading", count: images.count), ratio: ratio, videoURL: nil, thumbVideo: nil, duration: nil, completion: { error, messRef in
            guard let messRef = messRef, error == nil else {
                completion(error)
                return
            }
            // send video affter send image
            self.sendVideo(videos: videos, completion: completion)
            var listURL: [String] = []
            for image in images {
                FirebaseManager.shared.uploadImageToStorage(with: image) { url, error in
                    guard let url = url, error == nil else {
                        completion(error)
                        return
                    }
                    listURL.append("\(url)")
                    if listURL.count == images.count {
                        FirebaseManager.shared.updateImageMessage(messRef: messRef, images: listURL, videoURL: "", thumbVideo: "") { err in
                            guard err == nil else {
                                completion(err)
                                return
                            }
                            completion(nil)
                        }
                    }
                }
            }
        })
    }
    
    func sendVideo(videos: [AssetModel], completion: @escaping(Error?)->Void) {
        self.getDataVideo(assets: videos) { results in
            guard let results = results else {
                return
            }
            for (index, result) in results.enumerated() {
                let urlVideo = result.0
                let thumb = result.1
                print("video: ", urlVideo)
                let ratio = thumb.size.height/thumb.size.width
                self.didTapSendMessage(type: .video, images: nil, ratio: ratio, videoURL: "", thumbVideo: "", duration: videos[index].duration) { error, messRef in
                    guard let messRef = messRef, error == nil else {
                        completion(error)
                        return
                    }
                    print("video: ", urlVideo)
                    
                    FirebaseManager.shared.uploadVideo(url: urlVideo, thumb: thumb, messRef: messRef) {error in
                        guard error == nil else {
                            completion(error)
                            return
                        }
                        completion(nil)
                    }
                }
            }
        }
    }
    
    func sendFile(fileName: String, fileURL: URL, completion: @escaping(Error?)->Void) {
        self.didTapSendMessage(type: .file, fileName: fileName) { error, messRef in
            guard let messRef = messRef, error == nil else {
                completion(error)
                return
            }
            FirebaseManager.shared.uploadFile(messRef: messRef, fileURL: fileURL) { err in
                completion(err)
            }
        }
    }
    
    func sendAudio(audioURL: URL, duration: Double, completion: @escaping(Error?)->Void) {
        self.didTapSendMessage(type: .audio, audioURL: "\(audioURL)", duration: duration) { error, messRef in
            guard let messRef = messRef else {
                return
            }
            FirebaseManager.shared.uploadAudio(url: audioURL, messRef: messRef, completion: completion)
        }
    }
    
    func getDataAndSent(assets: [AssetModel], completion: @escaping(Error?)->Void) {
        var listImages: [AssetModel] = []
        var listVideos: [AssetModel] = []
        for asset in assets {
            if asset.type == .image {
                listImages.append(asset)
            } else {
                listVideos.append(asset)
            }
        }
        // check if images.count == 0, send video else send images
        if listImages.count > 0 {
            self.getDataImage(assets: listImages) { images in
                self.sendImage(images: images, videos: listVideos, completion: completion)
            }
        } else {
            sendVideo(videos: listVideos, completion: completion)
        }
        
    }
    
    func getDataImage(assets: [AssetModel], completion: @escaping([UIImage]) -> Void) {
        var listImages: [UIImage] = []
        for asset in assets {
            // handle image
            let manager = PHImageManager.default()
            let requestOptions = PHImageRequestOptions()
            requestOptions.isNetworkAccessAllowed = true
            
            // Fetch the image data
            manager.requestImageDataAndOrientation(for: asset.asset, options: requestOptions) { imageData, _, _, _ in
                if let imageData = imageData {
                    let img = UIImage(data: imageData)!
                    listImages.append(img)
                    if listImages.count == assets.count {
                        completion(listImages)
                    }
                    // Generate a unique file name for the image
                    
                } else {
                    print("Can't get url")
                    listImages.append(Constants.Image.imageDefault)
                }
            }
        }
    }
    
    func getDataVideo(assets: [AssetModel], completion: @escaping([(URL, UIImage)]?) -> Void) {
        
        // handle video
        let manager = PHImageManager.default()
        let requestOptions = PHVideoRequestOptions()
        requestOptions.isNetworkAccessAllowed = true
        
        // Fetch the URL of the video
        var res: [(URL, UIImage)] = []
        for asset in assets {
            manager.requestAVAsset(forVideo: asset.asset, options: requestOptions, resultHandler: { (avAsset, audioMix, info) in
                guard let avURLAsset = avAsset as? AVURLAsset else {
                    completion(nil)
                    return
                    // Use the videoURL as needed
                }
                let videoURL = avURLAsset.url
                let requestOptions = PHImageRequestOptions()
                requestOptions.isSynchronous = true
                requestOptions.deliveryMode = .highQualityFormat
                
                PHImageManager.default().requestImage(for: asset.asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: requestOptions) { (image, info) in
                    guard let image = image else {
                        completion(nil)
                        return
                    }
                    res.append((videoURL, image))
                    if res.count == assets.count {
                        completion(res)
                    }
                }
            })
        }
    }
    
    func getListDetailItem() -> [DetailItem] {
        let listMess = self.listMessages
        var listDetail = [DetailItem]()
        for mess in listMess {
            if mess.type == .image {
                for url in mess.imageURL ?? [] {
                    let item = DetailItem(type: .image, url: url)
                    listDetail.append(item)
                }
                
            } else if mess.type == .video {
                let item = DetailItem(type: .video, url: mess.videoURL ?? "", isPlaying: true, currentTime: 0.0, duration: mess.duration ?? 0.0)
                listDetail.append(item)
            }
        }
        return listDetail
    }
    
    func calculateHeightMessage(messageWidth: CGFloat, section: Int, index: Int) -> CGFloat {

        let listItem = self.listSectionsMessages.value[section]

        let messageSend = listItem.items[index]
        switch messageSend.type {
        case.image :
            guard let count = messageSend.imageURL?.count else {
                return UITableView.automaticDimension
            }
            if count > 1 {
                var div: CGFloat
                var spaceColumn: CGFloat
                var numberColumn: CGFloat
                if count == 2  || count == 4 {
                    div = CGFloat(count)/2
                    spaceColumn = CGFloat(2)
                    numberColumn = 2
                } else {
                    div = ceil(Double(count)/3)
                    spaceColumn = CGFloat(2) * 2
                    numberColumn = 3
                }
                let spaceRow = CGFloat(2 * (Int(div) - 1))
                let widthImage = (messageWidth - spaceColumn)/numberColumn
                return widthImage * div + spaceRow + 45
            } else {
                return  messageWidth * (messageSend.ratioImage ?? 1) + 45
            }
        case .video:
            print("rtio:", messageSend.ratioImage)
            return messageWidth * (messageSend.ratioImage ?? 1) + 45
            
        default:
            return UITableView.automaticDimension
        }
    }

    func scrollToBottom(tableView: UITableView?){
        if self.listMessages.count > 0 {
            DispatchQueue.main.async { [weak self] in
                let lastSections = self?.listSectionsMessages.value.last
                let indexPath = IndexPath(row: (lastSections?.items.count)! - 1, section: (self?.listSectionsMessages.value.count)! - 1)
                tableView?.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        }
    }
    
    func setContentOffsetOfTableView(tableView: UITableView?, messages: [MessageModel]) {
        guard let tableView = tableView else {
            return
        }
        DispatchQueue.main.async {
            var newOffset = tableView.contentOffset
            for i in 0..<messages.count{
                let indexPath = IndexPath(row: i, section: 0)
                let cellRect = tableView.rectForRow(at: indexPath)
                newOffset.y += cellRect.height
            }
            tableView.contentOffset = newOffset
        }
    }
    var view = UIView()
    func reloadData(tableView: UITableView) {
        DispatchQueue.main.async { [weak self] in
            tableView.reloadData()
            self?.scrollToBottom(tableView: tableView)
        }
    }
    //MARK: File
    func previewFileFromURL(url: URL, completion: @escaping(URL?, Error?)->Void) {
        //download file
        guard let fileName = self.getFileNameFromURL(fileURL: url) else {
            completion(nil, NSError(domain: "com.example.error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Don't get file name!"]))
            return
        }
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let localFileURL = documentsDirectory.appendingPathComponent(fileName)
        if fileManager.fileExists(atPath: localFileURL.path) {
            print("file Exist", fileName)
            completion(localFileURL, nil)
            // file exists
        } else {
            DispatchQueue.global(qos: .background).async {
                let downloadTask = URLSession.shared.downloadTask(with: url) { (location, response, error) in
                    if let location = location {
                        do {
                            // move item to local file
                            try fileManager.moveItem(at: location, to: localFileURL)
                            completion(localFileURL, nil)
                            print("File saved to local path: \(localFileURL.path)")
                        } catch {
                            completion(nil, NSError(domain: "com.example.error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Save file to local Error!"]))
                            print("Failed to save file to local path: \(error.localizedDescription)")
                        }
                    }
                }
                downloadTask.resume()
            }
        }
        
    }
    
    func getFileNameFromURL(fileURL: URL) -> String? {
        if let unescapedURL = fileURL.absoluteString.removingPercentEncoding,
           let unescapedFileURL = URL(string: unescapedURL) {
            return unescapedFileURL.lastPathComponent
        }
        return nil
    }
    
    func setAppInScreenChat(isScreenChat: Bool) {
        FirebaseManager.shared.updateStatusChating(isChating: isScreenChat)
        guard let roomRef = roomRef , let uid = self.uid else {
            return
        }
        
        FirebaseManager.shared.updateUnreadMessage(id: uid, clearUnread: true, roomRef: roomRef)
    }
}
