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
                                               success: @escaping (T) -> Void,
                                               failure: @escaping (_ message: String) -> Void) {
        path.getDocument { document, error in
            guard let data = document?.data(), error == nil else {
                print(error?.localizedDescription ?? "eror")
                failure(error?.localizedDescription ?? "request firestore error!")
                return
            }
            success(T(json: data))
        }

    }
    
    func updateData(path: DocumentReference, data: [String: Any]) {
        path.updateData(data)
    }

    func setData(path: DocumentReference, data: [String: Any],
                 success: @escaping (Bool) -> Void,
                 failure: @escaping (_ message: String) -> Void) {
        path.setData(data) { error in
            if error == nil {
                success(true)
            } else {
                failure(error!.localizedDescription)
            }
        }
    }
    
    func uploadFile(fileURL: URL,
                    fileType: StoragePath,
                    success: @escaping (URL) -> Void,
                    failure: @escaping (_ message: String) -> Void) {
        guard let uid = UserDefaultManager.shared.getID() else {
            failure("Can't fetch user id!")
            return
        }
        do {
            let fileName = [uid, String(Date().timeIntervalSince1970)].joined()
            let data = try Data(contentsOf: fileURL)
            let storageRef = storage.child(fileType.rawValue).child(fileName)
            let metaData = StorageMetadata()
            switch fileType {
            case .audios:
                metaData.contentType = "audio/m4a"
            case .videos:
                metaData.contentType = "video/mp4"
            default:
                break
            }
            storageRef.putData(data, metadata: metaData
                               , completion: { (metadata, error) in
                guard error == nil else {
                    failure(error!.localizedDescription)
                    return
                }
                storageRef.downloadURL { (urlVideo, err) in
                    guard let urlVideo = urlVideo else {
                        failure(err!.localizedDescription)
                        return
                    }
                    success(urlVideo)
                }
            })
        } catch (let error) {
            failure(error.localizedDescription)
        }
    }
    
    func uploadImage(image: UIImage,
                     fileType: StoragePath = .images,
                     success: @escaping (URL) -> Void,
                     failure: @escaping (_ message: String) -> Void) {
        guard let uid = UserDefaultManager.shared.getID() else {
            failure("Can't fetch user id!")
            return
        }
        
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            failure("Can't fetch data from image!")
            return
        }
        let fileName = [uid, String(Date().timeIntervalSince1970)].joined()
        let storageRef = storage.child(fileType.rawValue).child(fileName)
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpeg"
        storageRef.putData(data, metadata: metaData
                           , completion: { (metadata, error) in
            guard error == nil else {
                failure(error!.localizedDescription)
                return
            }
            storageRef.downloadURL { (urlVideo, err) in
                guard let urlVideo = urlVideo else {
                    failure(err!.localizedDescription)
                    return
                }
                success(urlVideo)
            }
        })
    }
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
    
    func rxRequestDocument<T: JsonInitObject>(path: DocumentReference) -> Observable<T> {
        Observable<T>.create { observable -> Disposable in
            self.requestDocument(path: path) { data in
                observable.onNext(data)
            } failure: { message in
                observable.onError(AppError(code: .firebase, message: message))
            }
            return Disposables.create()
        }
    }
    
    func rxSetData(path: DocumentReference, data: [String : Any]) -> Observable<Bool> {
        Observable<Bool>.create { observable -> Disposable in
            self.setData(path: path, data: data) { isSuccess in
                observable.onNext(isSuccess)
            } failure: { message in
                observable.onError(AppError(code: .firebase, message: message))
            }

            return Disposables.create()
        }
    }
    
    func rxUploadFile(fileURL: URL, fileType: StoragePath) -> Observable<URL> {
        Observable<URL>.create { observable -> Disposable in
            self.uploadFile(fileURL: fileURL, fileType: fileType) { url in
                observable.onNext(url)
            } failure: { message in
                observable.onError(AppError(code: .firebase, message: message))
            }
            return Disposables.create()
        }
    }
    
    func rxUploadImage(image: UIImage) -> Observable<URL> {
        Observable<URL>.create { observable -> Disposable in
            self.uploadImage(image: image) { url in
                observable.onNext(url)
            } failure: { message in
                observable.onError(AppError(code: .firebase, message: message))
            }
            return Disposables.create()
        }
    }
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
