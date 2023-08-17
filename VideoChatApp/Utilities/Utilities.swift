//
//  Utilities.swift
//  VideoChatApp
//
//  Created by Khanh Vu on 08/05/5 Reiwa.
//

import Foundation
import UIKit
import FirebaseFirestore
import AVFoundation
final class Utilitis {
    static let shared = Utilitis()
    
    func setBadgeIcon(number: Int) {
        UIApplication.shared.applicationIconBadgeNumber = number
    }
    
    func convertToString(timestamp: Timestamp, formatter: String? = "hh:mm") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatter
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp.seconds))
//        let date = timestamp // replace with your own Firestore Date object
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
    func convertDurationToTime(duration: Double) -> String {
        let minutes = Int(duration / 60)
        let seconds = Int(Int(duration) - minutes * 60)
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func deleteFile(at url: URL) {
        guard FileManager.default.fileExists(atPath: url.path) else {
            return
        }
        do {
            try FileManager.default.removeItem(at: url)
            print("File deleted successfully.")
        } catch {
            print("Error deleting file: \(error.localizedDescription)")
        }
    }
    
    func extractFileName(from url: URL) -> String? {
        let components = url.pathComponents
        if let lastComponent = components.last {
            return lastComponent
        }
        return nil
    }
    
    func bytesToMegabytes(bytes: Int64) -> Double {
        let megabytes = Double(bytes) / 1_048_576.0
        return megabytes
    }
    
    func compressVideo(url: URL?, completion: @escaping ((URL) -> Void)) {
        guard let url = url else {
            return
        }
        
        let asset = AVAsset(url: url)
        let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetMediumQuality)
        
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let compressedVideoURL = documentsPath.appendingPathComponent("compressedVideo.mp4")
        
        if FileManager.default.fileExists(atPath: compressedVideoURL.path) {
            try? FileManager.default.removeItem(at: compressedVideoURL)
        }
        
        exportSession?.outputURL = compressedVideoURL
        exportSession?.outputFileType = AVFileType.mp4
        exportSession?.shouldOptimizeForNetworkUse = true
        exportSession?.exportAsynchronously {
            completion(compressedVideoURL)
        }
    }
    
    func getVideoFileSize(url: URL) -> Int64? {
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: url.path)
            if let fileSize = fileAttributes[.size] as? Int64 {
                return fileSize
            }
        } catch {
            print("Error getting file size: \(error)")
        }
        return nil
    }
    
    func getBitRateFromURL(url: URL) -> Float{
        let videoAsset = AVURLAsset(url: url)
        guard let videoTrack = videoAsset.tracks(withMediaType: AVMediaType.video).first else {
            print("Cannot find video track")
            return 0
        }
        return videoTrack.estimatedDataRate
    }
    
    func estimateFileSize(bitrate: Float, duration: Double) -> Float {
        return (bitrate * 1000000 * Float(duration)) / (8 * 1024 * 1024)
    }
}
