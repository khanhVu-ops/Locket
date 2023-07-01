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
    func convertDateToTimeString() -> String{
        let dateFormatter = DateFormatter()
        let calendar = Calendar.current // lấy lịch hiện tại
        let year = calendar.component(.year, from: self.dateValue()) // lấy giá trị năm từ đối tượng date
        let isCurrentDay = Calendar.current.isDate(self.dateValue(), inSameDayAs: Date())

        let isCurrentYear = year == calendar.component(.year, from: Date())
        if isCurrentDay {
            dateFormatter.dateFormat = 
        }
        isCurrentYear ? (dateFormatter.dateFormat = "MMMM d") : (dateFormatter.dateFormat = "MMMM d, yyyy")
        let dateString = dateFormatter.string(from: self)
        return dateString
    }
}
