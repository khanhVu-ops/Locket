//
//  APIService.swift
//  VideoChatApp
//
//  Created by Khanh Vu on 28/04/5 Reiwa.
//

import Foundation
import Alamofire
import RxSwift
import RxCocoa
final class APIService {
    static let shared = APIService()
    
    func pushNotificationMessage(fcmToken: [String]?, uid: String?, title: String?, body: String, badge: Int?) {
        guard let fcmToken = fcmToken, let uid = uid, let title = title, let badge = badge else {
            return
        }

        let headers: HTTPHeaders = [
            "Authorization": "key=\(RCValues.shared.string(forKey: .fcmServerKey))",
            "Content-Type": "application/json"
        ]
        //body
        let parameters: Parameters = [
             "registration_ids" : fcmToken,
             "notification" : [
                "title" : title,
                "body": body,
                "icon": "icon_notification",
                "sound": "default",
                "content_available": true,
                "badge": badge,
                "data": [
                    "uid": uid,
                    "screen_name": "ChatViewController"
                ]
             ]
        ]

        self.requestAPI(url: RCValues.shared.string(forKey: .fcmURL), method: .post, headers: headers, parameters: parameters) { result in
            switch result {
                case .success(let value):
                    // Xử lý dữ liệu thành công
                    print("push notification success")
                case .failure(let error):
                    // Xử lý lỗi
                print(error.localizedDescription)
            }
        }
    }
    
    func requestAPI(url: String, method: HTTPMethod, headers: HTTPHeaders?, parameters: Parameters?, completion: @escaping (Result<Any, Error>) -> Void) {
        AF.request(url, method: method, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            switch response.result {
            case .success(let value):
                completion(.success(value))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
