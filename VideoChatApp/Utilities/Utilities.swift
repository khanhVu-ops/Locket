//
//  Utilities.swift
//  VideoChatApp
//
//  Created by Khanh Vu on 08/05/5 Reiwa.
//

import Foundation
import UIKit
import FirebaseFirestore
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
}
