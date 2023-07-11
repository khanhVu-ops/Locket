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
    let fcmServerKey = "AAAAxstpRhA:APA91bGKZ-t33ISHCUx-lk7pgHGD0Br3HRowvLwGiZ9J3VVcfTTdb7jw5I0o6QceAWOQ5rzE7yCfr4_TFtRhm6w8G6F4CiiUNApu_3ALfJEzQsusQLU_k1is2vpIBe57sUUel0IfESvN"
    let notificationURL = "https://fcm.googleapis.com/fcm/send"
    func pushNotificationMessage(fcmToken: [String]?, uid: String?, title: String?, body: String, badge: Int?) {
        guard let fcmToken = fcmToken, let uid = uid, let title = title, let badge = badge else {
            return
        }
        guard let url = URL(string: notificationURL) else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        // header
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("key=\(self.fcmServerKey)", forHTTPHeaderField: "Authorization")

        //body
        let parameters = [
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
    
//    static func rxRequestModel<T: Decodable>(
//        method apiMethod: HTTPMethod = .get,
//        apiPath path: String,
//        params parameters: [String: Any]? = nil,
//        configArrayForMethodGet config: Bool = false,
//        headers headerParams: [String: String]? = nil,
//        isToast: Bool = false,
//        isCheckNetwork: Bool = false) -> Observable<T> {
//            // isCheckNetwork == true cho những màn không cần hiện thị toast "Không có kết nối mạng"
////        if !Connectivity.isConnectedToInternet, isCheckNetwork == false {
////            ToastUtil.show(L10n.noInternet)
////        }
//            
//        // header
////        let mergeHeaders = self.mergeDefaultHeaders(headerParams)
//        
//        // parameter
////        var mergeParameters = parameters
////        if let defaultParameters = defaultParameters {
////            mergeParameters = defaultParameters.merging(parameters ?? [String: Any]()) { _, new in new }
////        }
//            
//        let encoding: ParameterEncoding = apiMethod == .get ? URLEncoding.default : JSONEncoding.default
//        return Observable.create({ observer -> Disposable in
//            APIService.shared.sessionManager.request(path.fullUrlStringWithAPIBaseURL(), method: apiMethod, parameters: parameters, headers: headerParams)
//                .validate(statusCode: 200..<APIService.validateStatusCode)
//                .responseJSON { dataResponse in
//                    switch dataResponse.result {
//                    case .success(let resultData):
//                        if ConfigManager.shared.getConfig(withType: .CONSOLE_SHOW_REQUEST_LOG) == "YES" {
//                            print(JSON(resultData))
//                        }
//                         observer.onNext(CodableUtil<T>.decodeFrom(JSON(resultData)))
//                        if isToast {
//                            AppObserver.shared.getSuccessMessageSubject().onNext(JSON(resultData)["msg"].string ?? "")
//                        }
//                    case .failure(let error):
//                        if ConfigManager.shared.getConfig(withType: .CONSOLE_SHOW_REQUEST_LOG) == "YES" {
//                            print(JSON(error))
//                        }
//                        if  dataResponse.response?.statusCode == 401 {
//                            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
//                                appDelegate.makeLogin()
//                            }
//                            return
//                        }
//                        observer.onError(dataResponse.errorResponseWithError(error))
//                    }
//                    observer.onCompleted()
//            }
//            
//            return Disposables.create()
//        }).debug().unwrap()
//    }
}
