//
//  MessageModel.swift
//  ChatApp
//
//  Created by Vu Khanh on 07/03/2023.
//

import Foundation
import FirebaseFirestore

enum MessageType: String {
    case text = "text"
    case image = "image"
    case video = "video"
    case audio = "audio"
    case file = "file"
}
class MessageModel {
    var type: MessageType?
    var message: String?
    var imageURL: [String]?
    var ratioImage: Double?
    var thumbVideo: String?
    var videoURL: String?
    var duration: Double?
    var audioURL: String?
    var fileName: String?
    var fileURL: String?
    var senderID: String?
    var progress: Double?
    var created: Timestamp?
    

    convenience init(type: MessageType, message: String? = nil, imageURL: [String]? = nil, ratioImage: Double? = nil, thumbVideo: String? = nil, videoURL: String? = nil, audioURL: String? = nil, duration: Double? = nil, fileName: String? = nil, fileURL: String? = nil, progress: Double? = nil, senderID: String, created: Timestamp) {
        self.init()
        self.type = type
        self.message = message
        self.imageURL = imageURL
        self.ratioImage = ratioImage
        self.thumbVideo = thumbVideo
        self.videoURL = videoURL
        self.audioURL = audioURL
        self.duration = duration
        self.fileName = fileName
        self.fileURL = fileURL
        self.progress = progress
        self.senderID = senderID
        self.created = created
    }
    
    convenience init(json: [String: Any]) {
        self.init()
        for (key, value) in json {
            if key == "type", let wrapValue = value as? String {
                if wrapValue == "video" {
                    self.type = .video
                } else if wrapValue == "image" {
                    self.type = .image
                } else if wrapValue == "file" {
                    self.type = .file
                } else if wrapValue == "audio" {
                    self.type = .audio
                } else {
                    self.type = .text
                }
            }
            if key == "message", let wrapValue = value as? String {
                self.message = wrapValue
            }
            if key == "imageURL", let wrapValue = value as? [String] {
                self.imageURL = wrapValue
            }
            if key == "ratioImage", let wrapValue = value as? Double {
                self.ratioImage = wrapValue
            }
            if key == "thumbVideo", let wrapValue = value as? String {
                self.thumbVideo = wrapValue
            }
            if key == "videoURL", let wrapValue = value as? String {
                self.videoURL = wrapValue
            }
            if key == "audioURL", let wrapValue = value as? String {
                self.audioURL = wrapValue
            }
            if key == "duration", let wrapValue = value as? Double {
                self.duration = wrapValue
            }
            if key == "fileName", let wrapValue = value as? String {
                self.fileName = wrapValue
            }
            if key == "fileURL", let wrapValue = value as? String {
                self.fileURL = wrapValue
            }
            if key == "progress", let wrapValue = value as? Double {
                self.progress = wrapValue
            }
            if key == "senderID", let wrapValue = value as? String {
                self.senderID = wrapValue
            }
            if key == "created", let wrapValue = value as? Timestamp {
                self.created = wrapValue
            }
           
        }
    }
    
    func convertToDictionary() -> [String: Any] {
        return [
            "type": self.type?.rawValue ?? "",
            "message": self.message ?? "",
            "imageURL": self.imageURL ?? [],
            "ratioImage": self.ratioImage ?? 1.0,
            "thumbVideo": self.thumbVideo ?? "",
            "videoURL": self.videoURL ?? "",
            "audioURL": self.audioURL ?? "",
            "duration": self.duration ?? 0.0,
            "fileName": self.fileName ?? "",
            "fileURL": self.fileURL ?? "",
            "progress": self.progress ?? 0.0,
            "senderID": self.senderID ?? "",
            "created": self.created ?? "",
        ] as [String : Any]
    }
}
