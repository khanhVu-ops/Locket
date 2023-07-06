//
//  MessageModel.swift
//  ChatApp
//
//  Created by Vu Khanh on 07/03/2023.
//

import Foundation
import FirebaseFirestore
import Photos

enum MessageType: Int {
    case text = 1
    case image = 2
    case video = 3
    case audio = 4
    case file = 5
}

enum MessageStatus: String {
    case sent = "sent"
    case seen = "seen"
    case sending = "sending"
}

enum UploadStatus: String {
    case loading = "loading"
    case success = "success"
    case error = "error"
}

class MediaModel: NSObject {
    var type: MessageType?
    var filePath: URL?
    var fileName: String? = ""
    var asset: PHAsset?
    var thumbnail: UIImage?
    var ratio: Double = 1
    var duration: Double?
    var isSelect = false
    convenience init(asset: PHAsset) {
        self.init()
        self.asset = asset
        self.type = asset.mediaType == .image ? .image : .video
        self.duration = asset.duration
    }
    
    convenience init(fileURL: URL, fileName: String, fileSize: Double) {
        self.init()
        self.filePath = fileURL
        self.fileName = fileName
        self.duration = fileSize
        self.type = .file
    }
    
    convenience init(audioURL: URL, duration: Double) {
        self.init()
        self.filePath = audioURL
        self.type = .audio
        self.duration = duration
    }
}

class MessageModel: NSObject, JsonInitObject {
    var type: MessageType?
    var messageID: String?
    var message: String?
    var imageURL: [String]?
    var ratioImage: Double?
    var fileURL: String?
    var duration: Double?
    var fileName: String?
    var senderID: String?
    var created: Timestamp?
    var isBubble = false
    var status: MessageStatus = .sending

    convenience init(type: MessageType, messageID: String? = nil, message: String? = nil, imageURL: [String]? = nil, fileURL: String? = nil, ratioImage: Double? = nil, duration: Double? = nil, fileName: String? = nil, senderID: String, created: Timestamp) {
        self.init()
        self.type = type
        self.messageID = messageID
        self.message = message
        self.imageURL = imageURL
        self.fileURL = fileURL
        self.ratioImage = ratioImage
        self.duration = duration
        self.fileName = fileName
        self.senderID = senderID
        self.created = created
    }
    
    required convenience init(json: [String: Any]) {
        self.init()
        for (key, value) in json {
            if key == "type", let wrapValue = value as? Int {
                if wrapValue == 2 {
                    self.type = .image
                } else if wrapValue == 3 {
                    self.type = .video
                } else if wrapValue == 4 {
                    self.type = .audio
                } else if wrapValue == 5 {
                    self.type = .file
                } else {
                    self.type = .text
                }
            }
            if key == "messageID", let wrapValue = value as? String {
                self.messageID = wrapValue
            }
            if key == "message", let wrapValue = value as? String {
                self.message = wrapValue
            }
            if key == "imageURL", let wrapValue = value as? [String] {
                self.imageURL = wrapValue
            }
            if key == "fileURL", let wrapValue = value as? String {
                self.fileURL = wrapValue
            }
            if key == "ratioImage", let wrapValue = value as? Double {
                self.ratioImage = wrapValue
            }
            if key == "duration", let wrapValue = value as? Double {
                self.duration = wrapValue
            }
            if key == "fileName", let wrapValue = value as? String {
                self.fileName = wrapValue
            }
            if key == "senderID", let wrapValue = value as? String {
                self.senderID = wrapValue
            }
            if key == "created", let wrapValue = value as? Timestamp {
                self.created = wrapValue
            }
            if key == "status", let wrapValue = value as? String {
                switch wrapValue {
                case "sent":
                    self.status = .sent
                case "seen":
                    self.status = .seen
                default:
                    self.status = .sending
                }
            }
        }
    }
    
    func convertToDictionary() -> [String: Any] {
        return [
            "type": self.type?.rawValue ?? 1,
            "messageID": self.messageID ?? "",
            "message": self.message ?? "",
            "imageURL": self.imageURL ?? [],
            "ratioImage": self.ratioImage ?? 1.0,
            "fileURL": self.fileURL ?? "",
            "duration": self.duration ?? 0.0,
            "fileName": self.fileName ?? "",
            "senderID": self.senderID ?? "",
            "created": self.created ?? "",
            "status": self.status.rawValue ?? "sending"
        ] as [String : Any]
    }
}
