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
}
class MessageModel {
    var type: MessageType?
    var message: String?
    var imageURL: [String]?
    var ratioImage: Double?
    var thumbVideo: String?
    var videoURL: String?
    var duration: Double?
    var senderID: String?
    var created: Timestamp?
    

    convenience init(type: MessageType, message: String? = nil, imageURL: [String]? = nil, ratioImage: Double? = nil, thumbVideo: String? = nil, videoURL: String? = nil, duration: Double? = nil, senderID: String, created: Timestamp) {
        self.init()
        self.type = type
        self.message = message
        self.imageURL = imageURL
        self.ratioImage = ratioImage
        self.thumbVideo = thumbVideo
        self.videoURL = videoURL
        self.duration = duration
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
            if key == "duration", let wrapValue = value as? Double {
                self.duration = wrapValue
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
            "duration": self.duration ?? 0.0,
            "senderID": self.senderID ?? "",
            "created": self.created ?? "",
        ] as [String : Any]
    }
}
