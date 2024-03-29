//
//  BaseFirebaseService.swift
//  VideoChatApp
//
//  Created by Khanh Vu on 12/06/5 Reiwa.
//

import Foundation
import RxSwift
import RxCocoa
import FirebaseFirestore
import FirebaseStorage
import FirebaseCore


protocol JsonInitObject: NSObject {
    init(json: [String : Any])
}

class BaseFirebaseService {
    let fireStore = Firestore.firestore()
    let storage = Storage.storage().reference()
    var lastMessageSnapshot: QueryDocumentSnapshot?
    let usersClt = "users"
    let chatsClt = "chats"
    let conversationsClt = "conversations"
    func requestCollection<T: JsonInitObject>(path: Query,
                                              isListener: Bool,
                                              success: @escaping ([T]) -> Void,
                                              failure: @escaping (_ message: String) -> Void) {
        if isListener {
            path.addSnapshotListener { snapshot, error in
                guard let snapshot = snapshot, error == nil else {
                    failure(error!.localizedDescription)
                    return
                }
                var listObj: [T] = []
                if T() is MessageModel {
                    self.lastMessageSnapshot = snapshot.documents.last
                }
                for document in snapshot.documents {
                    let obj = T(json: document.data())
                    listObj.append(obj)
                }
                success(listObj)
            }
        } else {
            path.getDocuments { snapshot, error in
                guard let snapshot = snapshot, error == nil else {
                    failure(error!.localizedDescription)
                    return
                }
                var listObj: [T] = []
                for document in snapshot.documents {
                    let obj = T(json: document.data())
                    listObj.append(obj)
                }
                success(listObj)
            }
        }
    }
    
    func requestDocument<T: JsonInitObject>(path: DocumentReference,
                                            isListener: Bool,
                                            success: @escaping (T) -> Void,
                                            failure: @escaping (_ message: String) -> Void) {
        if isListener {
            path.addSnapshotListener { document, error in
                guard let data = document?.data(), error == nil else {
                    print(error?.localizedDescription ?? "eror")
                    failure(error?.localizedDescription ?? "request firestore error!")
                    return
                }
                success(T(json: data))
            }
        } else {
            path.getDocument { document, error in
                guard let data = document?.data(), error == nil else {
                    print(error?.localizedDescription ?? "eror")
                    failure(error?.localizedDescription ?? "request firestore error!")
                    return
                }
                success(T(json: data))
            }
        }
    }
    
    func updateData(path: DocumentReference, data: [String: Any]) {
        path.updateData(data)
    }

    func setData(path: DocumentReference, data: [String: Any],
                 success: @escaping (String) -> Void,
                 failure: @escaping (_ message: String) -> Void) {
        path.setData(data) { error in
            if error == nil {
                success(path.documentID)
            } else {
                failure(error!.localizedDescription)
            }
        }
    }
    
    func uploadMedia(fileType: MessageType,
                     fileURL: URL,
                    success: @escaping (String) -> Void,
                    failure: @escaping (_ message: String) -> Void) {
        guard let uid = UserDefaultManager.shared.getID() else {
            failure("Can't fetch user id!")
            return
        }
        do {
            let fileName = [String(Date().timeIntervalSince1970), fileURL.lastPathComponent].joined()
            print("file name: ",fileName)
            let data = try Data(contentsOf: fileURL)
            let storageRef = storage.child("\(fileType.rawValue)").child(uid).child(fileName)
            let metaData = StorageMetadata()
            switch fileType {
            case .image:
                metaData.contentType = "image/jpeg"
            case .audio:
                metaData.contentType = "audio/m4a"
            case .video:
                metaData.contentType = "video/mp4"
            default: break
            }
            storageRef.putData(data, metadata: metaData
                               , completion: { (metadata, error) in
                guard let metadata = metadata, error == nil else {
                    failure(error!.localizedDescription)
                    return
                }
                print("File size: \(Utilitis.shared.bytesToMegabytes(bytes: metadata.size))")

                storageRef.downloadURL { (url, err) in
                    guard let url = url else {
                        failure(err!.localizedDescription)
                        return
                    }
                    print(url)
                    success("\(url)")
                }
            })
        } catch (let error) {
            failure(error.localizedDescription)
        }
    }
    
    func uploadImage(image: UIImage?,
                     success: @escaping (String) -> Void,
                     failure: @escaping (_ message: String) -> Void) {
        guard let uid = UserDefaultManager.shared.getID(), let image = image else {
            failure("image nil")
            return
        }
        let fileName = [String(Date().timeIntervalSince1970), "images"].joined()
        let storageRef = storage.child("\(2)").child(uid).child(fileName)
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        let data = image.jpegData(compressionQuality: 0.5)
        storageRef.putData(data!, metadata: metaData) {meta, error in
            guard error == nil else {
                failure(error!.localizedDescription)
                return
            }
            
            storageRef.downloadURL { url, err in
                guard let url = url ,err == nil else {
                    failure(err!.localizedDescription)
                    return
                }
                success(url.absoluteString)
            }
        }
    }
    
    func deleteFile(at url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
            print("File deleted successfully.")
        } catch {
            print("Error deleting file: \(error.localizedDescription)")
        }
    }

    
//    func uploadImage(image: UIImage,
//                     fileType: StoragePath = .images,
//                     success: @escaping (URL) -> Void,
//                     failure: @escaping (_ message: String) -> Void) {
//        guard let uid = UserDefaultManager.shared.getID() else {
//            failure("Can't fetch user id!")
//            return
//        }
//
//        guard let data = image.jpegData(compressionQuality: 0.8) else {
//            failure("Can't fetch data from image!")
//            return
//        }
//        let fileName = [uid, String(Date().timeIntervalSince1970)].joined()
//        let storageRef = storage.child(fileType.rawValue).child(fileName)
//        let metaData = StorageMetadata()
//        metaData.contentType = "image/jpeg"
//        storageRef.putData(data, metadata: metaData
//                           , completion: { (metadata, error) in
//            guard error == nil else {
//                failure(error!.localizedDescription)
//                return
//            }
//            storageRef.downloadURL { (urlVideo, err) in
//                guard let urlVideo = urlVideo else {
//                    failure(err!.localizedDescription)
//                    return
//                }
//                success(urlVideo)
//            }
//        })
//    }
}

// MARK: rx + Observable

extension BaseFirebaseService {
    func rxRequestCollection<T: JsonInitObject>(path: Query,
                             isListener: Bool) -> Observable<[T]> {
        Observable<[T]>.create { observable -> Disposable in
            self.requestCollection(path: path, isListener: isListener) { data in
                observable.onNext(data)
            } failure: { message in
                observable.onError(AppError(code: .firebase, message: message))
            }
            return Disposables.create()
        }
    }
    
    func rxRequestDocument<T: JsonInitObject>(path: DocumentReference, isListener: Bool) -> Observable<T> {
        Observable<T>.create { observable -> Disposable in
            self.requestDocument(path: path, isListener: isListener) { data in
                observable.onNext(data)
            } failure: { message in
                observable.onError(AppError(code: .firebase, message: message))
            }
            return Disposables.create()
        }
    }
    
    func rxSetData(path: DocumentReference, data: [String : Any]) -> Observable<String> {
        Observable<String>.create { observable -> Disposable in
            self.setData(path: path, data: data) { documentID in
                observable.onNext(documentID)
                observable.onCompleted()
            } failure: { message in
                observable.onError(AppError(code: .firebase, message: message))
            }

            return Disposables.create()
        }
    }
    
    
    
    func rxUploadMedia(fileType: MessageType, fileURL: URL?) -> Observable<String> {
        Observable<String>.create { observable -> Disposable in
            if let fileURL = fileURL {
                self.uploadMedia(fileType: fileType, fileURL: fileURL) { url in
                    observable.onNext(url)
                    observable.onCompleted()
                } failure: { message in
                    observable.onError(AppError(code: .firebase, message: message))
                }
//                Utilitis.shared.compressVideo(url: fileURL, type: fileType) { urlCompressed in
//                    print("compressed: \(urlCompressed)")
//                    self.uploadMedia(fileType: fileType, fileURL: urlCompressed) { url in
//                        observable.onNext(url)
//                        observable.onCompleted()
//                    } failure: { message in
//                        observable.onError(AppError(code: .firebase, message: message))
//                    }
//                }
            } else {
                 observable.onError(AppError(code: .firebase, message: "Not found URL!"))
            }
            return Disposables.create()
        }
    }
//    func rxUploadImage(image: UIImage) -> Observable<URL> {
//        Observable<URL>.create { observable -> Disposable in
//            self.uploadImage(image: image) { url in
//                observable.onNext(url)
//            } failure: { message in
//                observable.onError(AppError(code: .firebase, message: message))
//            }
//            return Disposables.create()
//        }
//    }
}

//MARK: rx + BaseService + Single
//extension BaseFirebaseService {
//    func rxRequestCollection<T: JsonInitObject>(path: Query,
//                             isListener: Bool) -> Single<[T]> {
//        Single<[T]>.create { single in
//
//            self.requestCollection(path: path, isListener: isListener) { data in
//                single(.success(data))
//            } failure: { message in
//                single(.failure(AppError(code: .firebase, message: message)))
//            }
//            return Disposables.create()
//        }
//    }
//
//    func rxRequestDocumentSingle<T: JsonInitObject>(path: DocumentReference) -> Single<T> {
//        Single<T>.create { single in
//            self.requestDocument(path: path) { data in
//                single(.success(data))
//            } failure: { message in
//                single(.failure(AppError(code: .firebase, message: message)))
//            }
//            return Disposables.create()
//        }
//    }
//
//    func rxSetData(path: DocumentReference, data: [String : Any]) -> Single<Bool> {
//        Single.create { single in
//            self.setData(path: path, data: data) { isSuccess in
//                single(.success(isSuccess))
//            } failure: { message in
//                single(.failure(AppError(code: .firebase, message: message)))
//            }
//
//            return Disposables.create()
//        }
//    }
//
//    func rxUploadFile(fileURL: URL, fileType: StoragePath) -> Single<URL> {
//        Single<URL>.create { single in
//            self.uploadFile(fileURL: fileURL, fileType: fileType) { url in
//                single(.success(url))
//            } failure: { message in
//                single(.failure(AppError(code: .firebase, message: message)))
//            }
//            return Disposables.create()
//        }
//    }
//
//    func rxUploadImage(image: UIImage) -> Single<URL> {
//        Single<URL>.create { single in
//            self.uploadImage(image: image) { url in
//                single(.success(url))
//            } failure: { message in
//                single(.failure(AppError(code: .firebase, message: message)))
//            }
//            return Disposables.create()
//        }
//    }
//}
