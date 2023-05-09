//
//  Extensions+Date.swift
//  VideoChatApp
//
//  Created by Khanh Vu on 08/05/5 Reiwa.
//

import Foundation
import UIKit

extension Date {
    func convertDateToHeaderString() -> String{
        let dateFormatter = DateFormatter()
        let calendar = Calendar.current // lấy lịch hiện tại
        let year = calendar.component(.year, from: self) // lấy giá trị năm từ đối tượng date

        let isCurrentYear = year == calendar.component(.year, from: Date())
        isCurrentYear ? (dateFormatter.dateFormat = "MMMM d") : (dateFormatter.dateFormat = "MMMM d, yyyy")
        let dateString = dateFormatter.string(from: self)
        return dateString
    }
}
