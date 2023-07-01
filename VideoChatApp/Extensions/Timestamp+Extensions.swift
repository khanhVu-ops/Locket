//
//  Extensions+Date.swift
//  VideoChatApp
//
//  Created by Khanh Vu on 08/05/5 Reiwa.
//

import Foundation
import UIKit
import FirebaseFirestore
extension Timestamp {
    func convertTimestampToTimeString() -> String{
        let dateFormatter = DateFormatter()
        let calendar = Calendar.current // lấy lịch hiện tại
        let currentDate = Date()
        let dateValue = self.dateValue()
        let isCurrentDay = Calendar.current.isDate(dateValue, inSameDayAs: currentDate)
        let isCurrentWeek = calendar.isDate(dateValue, equalTo: currentDate, toGranularity: .weekOfYear)
        let isCurrentYear = calendar.isDate(dateValue, equalTo: currentDate, toGranularity: .year)
        if isCurrentDay {
            dateFormatter.dateFormat = "H:mm a"
        } else if isCurrentWeek {
            dateFormatter.dateFormat = "E H:mm a"
        } else if isCurrentYear {
            dateFormatter.dateFormat = "MMMM d 'at' H:mm a"
        } else {
            dateFormatter.dateFormat = "MMMM d, yyyy 'at' H:mm a"
        }
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        let dateString = dateFormatter.string(from: self.dateValue()).uppercased()
        return dateString
    }
}
