//
//  APIService.swift
//  VideoChatApp
//
//  Created by Khanh Vu on 28/04/5 Reiwa.
//

import Foundation

final class APIService {
    static let shared = APIService()
    let fcmServerKey = "AAAAxstpRhA:APA91bGKZ-t33ISHCUx-lk7pgHGD0Br3HRowvLwGiZ9J3VVcfTTdb7jw5I0o6QceAWOQ5rzE7yCfr4_TFtRhm6w8G6F4CiiUNApu_3ALfJEzQsusQLU_k1is2vpIBe57sUUel0IfESvN"
    func pushNotificationMessage(fcmToken: String?, uid: String?, title: String?, body: String) {
        guard let fcmToken = fcmToken, let uid = uid, let title = title else {
            return
        }
        guard let url = URL(string: "https://fcm.googleapis.com/fcm/send") else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        // header
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("key=\(self.fcmServerKey)", forHTTPHeaderField: "Authorization")

        //body
        let parameters = [
             "to" : fcmToken,
             "notification" : [
                "title" : title,
                "body": body,
                "icon": "icon_notification",
                "sound": "default",
                "content_available": true,
                "data": [
                    "uid": uid,
                    "screen_name": "ChatViewController"
                ]
             ]
        ] as [String : Any]
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)

        //datatask
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            // Xử lý kết quả trả về từ API
            if let error = error {
                print("Lỗi khi gửi yêu cầu API: \(error.localizedDescription)")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Lỗi khi nhận phản hồi từ API")
                return
            }
            if let data = data {
                // Xử lý dữ liệu trả về từ API ở đây
                let json = try? JSONSerialization.jsonObject(with: data, options: [])
                print(json)
            }
        }
        task.resume()
    }
}
