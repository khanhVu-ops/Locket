//
//  FirestoreManager.swift
//  ChatApp
//
//  Created by Vu Khanh on 09/03/2023.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage

protocol FirestoreManagerProtocol {
    func createUser(username: String, password: String, completion: @escaping (Error?) -> Void)
    func getUsers(completion: @escaping ([UserModel]?, Error?) -> Void)
    func getUsersLogin(completion: @escaping ([UserModel]?, Error?) -> Void)
    func creatNewChat(newRoom: ChatModel, content: MessageModel, completion: @escaping (DocumentReference?, DocumentReference?, Error?) -> Void)
    func addNewMessage(content: MessageModel,docRef: DocumentReference, completion: @escaping(Error?, DocumentReference?)->Void)
    func updateImageMessage(messRef: DocumentReference, images: [String], videoURL: String, thumbVideo: String, completion: @escaping(Error?) -> Void)
    func updateFileMessage(messRef: DocumentReference, fileURL: String, completion: @escaping(Error?)->Void)
    func updateAvatar(url: String, completion: @escaping (Error?)->Void)
    func getListChats(completion: @escaping([ChatModel]?, [DocumentReference]?, Error?) -> Void)
    func getMessagesWithLastDoc(docRef: DocumentReference, lastDocument: QueryDocumentSnapshot?, limitQuery: Int, completion: @escaping([MessageModel]?, QueryDocumentSnapshot?, Error?)->Void)
    func getMessages(docRef: DocumentReference, completion: @escaping([MessageModel]?, QueryDocumentSnapshot?, Error?)->Void)
    func getDocumentReferenceWithUserID(userId2: String, completion: @escaping(DocumentReference?, Error?)->Void)
    func uploadImageToStorage(with image: UIImage, completion: @escaping(URL?, Error?) -> Void)
    func uploadVideo(url: URL, thumb: UIImage, messRef: DocumentReference, completion: @escaping(Error?) -> Void)
    func uploadFile(messRef:DocumentReference, fileURL: URL, completion: @escaping(Error?)-> Void)
    func updateUserActive(isActive: Bool, completion: @escaping(Error?)->Void)
    func updateProgress(messRef: DocumentReference, value: Double)
    func logOut(completion: @escaping (Error?) -> Void)
}

class FirebaseManager {
    static let shared: FirestoreManagerProtocol = FirestoreManager()
}
class FirestoreManager: FirestoreManagerProtocol {
    let db = Firestore.firestore()
    let storage = Storage.storage().reference()
    
    let usersCollection = Constants.DBCollectionName.users
    let chatsCollection = Constants.DBCollectionName.chats
    let threadCollection = Constants.DBCollectionName.thread
    
    func createUser(username: String, password: String, completion: @escaping (Error?) -> Void) {
        let ref = db.collection(usersCollection).document()
        let id = ref.documentID
        let newUser = UserModel(id: id, username: username, password: password, avataURL: "", isActive: true).convertToDictionary()
        ref.setData(newUser) {
            err in
            guard err == nil else {
                completion(err)
                return
            }
            UserDefaultManager.shared.updateIDWhenLogin(id: id)
            completion(nil)
        }
    }
    
    func getUsersLogin(completion: @escaping ([UserModel]?, Error?) -> Void) {
        db.collection(usersCollection).getDocuments{ (querySnapshot, err) in
            guard err == nil else {
                completion(nil, err)
                return
            }
            var users: [UserModel] = []
            for document in querySnapshot!.documents {
                let user = UserModel(json: document.data())
                users.append(user)
            }
            completion(users, nil)
        }
    }
    
    func getUsers(completion: @escaping ([UserModel]?, Error?) -> Void) {
        db.collection(usersCollection).addSnapshotListener { (querySnapshot, err) in
            guard err == nil else {
                completion(nil, err)
                return
            }
            var users: [UserModel] = []
            for document in querySnapshot!.documents {
                let user = UserModel(json: document.data())
                users.append(user)
            }
            completion(users, nil)
        }
    }
    
    func creatNewChat(newRoom: ChatModel, content: MessageModel, completion: @escaping (DocumentReference?, DocumentReference?, Error?) -> Void) {
        let data = newRoom.convertToDictionary()
        let docRef = Firestore.firestore().collection(chatsCollection).document()
        docRef.setData(data) { (error) in
            guard error == nil else {
                completion(nil, nil, error)
                return
            }
            self.addNewMessage(content: content, docRef: docRef) { err, messRef in
                guard err == nil else {
                    completion(nil, nil, err)
                    return
                }
                completion(docRef, messRef, nil)
            }
        }
    }
    
    func addNewMessage(content: MessageModel,docRef: DocumentReference, completion: @escaping(Error?, DocumentReference?)->Void) {
        let uid = UserDefaultManager.shared.getID()
        let data = content.convertToDictionary()
        let doc = docRef.collection(threadCollection).document()
        doc.setData(data, completion: { (error) in
            guard error == nil else {
                completion(error,nil)
                return
            }
            docRef.updateData([
                "lastMessage": content.message ?? "",
                "lastCreated": content.created ?? "",
                "lastSenderID": content.senderID ?? uid
            ]) { error in
                guard error == nil else {
                    completion(error, nil)
                    return
                }
                completion(nil, doc)
            }
            
        })
    }
    
    func updateImageMessage(messRef: DocumentReference, images: [String], videoURL: String, thumbVideo: String, completion: @escaping(Error?) -> Void) {
        messRef.updateData([
            "imageURL": images,
            "videoURL": videoURL,
            "thumbVideo": thumbVideo,
        ]) { error in
            completion(error)
        }
    }
    
    func updateFileMessage(messRef: DocumentReference, fileURL: String, completion: @escaping(Error?)->Void) {
        messRef.updateData([
            "fileURL": fileURL,
        ]) { error in
            completion(error)
        }
    }
    
    func updateAvatar(url: String, completion: @escaping (Error?)->Void) {
        let userID = UserDefaultManager.shared.getID()
        let ref = db.collection(usersCollection).document(userID)
        ref.updateData(["avataURL": url]) { error in
            completion(error)
        }
    }
    
    func getListChats(completion: @escaping([ChatModel]?, [DocumentReference]?, Error?) -> Void) {
        let userID = UserDefaultManager.shared.getID()
        let ref = db.collection(chatsCollection).whereField("users", arrayContains: userID).order(by: "lastCreated", descending: true)
        ref.addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot, error == nil else {
                completion(nil,nil, error)
                return
            }
            var listChats: [ChatModel] = []
            var listDocs: [DocumentReference] = []
            for document in snapshot.documents {
                let roomChat = ChatModel(json: document.data())
                listChats.append(roomChat)
                listDocs.append(document.reference)
            }
            completion(listChats,listDocs, nil)
        }
    }
    
    func getDocumentReferenceWithUserID(userId2: String, completion: @escaping(DocumentReference?, Error?)->Void) {
        let uid = UserDefaultManager.shared.getID()
        db.collection(chatsCollection).whereField("users", arrayContains: uid).getDocuments(completion: { snapshot, error in
            guard let snapshot = snapshot, error == nil else {
                completion(nil, error)
                return
            }
            for document in snapshot.documents {
                let room = ChatModel(json: document.data())
                if room.users?.contains(where: {$0 == userId2}) == true {
                    completion(document.reference, nil)
                }
            }
            completion(nil, nil)
        })
    }
    
    func getMessages(docRef: DocumentReference, completion: @escaping([MessageModel]?, QueryDocumentSnapshot?, Error?)->Void) {
        let query = docRef.collection(threadCollection).order(by: "created", descending: true).limit(to: 20)
        query.addSnapshotListener({ snapshot, error in
            guard let snapshot = snapshot, error == nil else {
                completion(nil, nil, error)
                return
            }
            var messages: [MessageModel] = []
            for document in snapshot.documents.reversed() {
                let mess = MessageModel(json: document.data())
                messages.append(mess)
            }
            completion(messages, snapshot.documents.last, nil)
        })
    }
    
    func getMessagesWithLastDoc(docRef: DocumentReference, lastDocument: QueryDocumentSnapshot?, limitQuery: Int, completion: @escaping([MessageModel]?, QueryDocumentSnapshot?, Error?)->Void) {
        guard let lastDocument = lastDocument else {
            return
        }
        let query = docRef.collection(threadCollection).order(by: "created", descending: true).limit(to: limitQuery).start(afterDocument: lastDocument)
        
        query.getDocuments(completion: { snapshot, error in
            guard let snapshot = snapshot, error == nil else {
                completion(nil, nil, error)
                return
            }
            var messages: [MessageModel] = []
            for document in snapshot.documents.reversed() {
                let mess = MessageModel(json: document.data())
                messages.append(mess)
            }
            completion(messages, snapshot.documents.last, nil)
        })
    }
    
    func uploadImageToStorage(with image: UIImage, completion: @escaping(URL?, Error?) -> Void) {
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        let uid = UserDefaultManager.shared.getID()
        let fileName = [uid, String(Date().timeIntervalSince1970)].joined()
        let data = image.jpegData(compressionQuality: 0.0)
        let storeRef = storage.child(uid).child(fileName)
        storeRef.putData(data!, metadata: metadata) { meta, error in
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            storeRef.downloadURL { url, err in
                guard let url = url ,err == nil else {
                    completion(nil, err)
                    return
                }
                completion(url, nil)
            }
        }
        
    }
    
    func uploadVideo(url: URL, thumb: UIImage, messRef: DocumentReference, completion: @escaping(Error?) -> Void) {
        print("URL:", url)
        let name = "\(url).mp4"
        do {
            let data = try Data(contentsOf: url)
            let storageRef = storage.child("Videos").child(name)
            let metaData = StorageMetadata()
            metaData.contentType = "video/mp4"
            let uploadTask = storageRef.putData(data, metadata: metaData
                               , completion: { (metadata, error) in
                guard error == nil else {
                    completion(error)
                    return
                }
                storageRef.downloadURL { (urlVideo, error) in
                    guard let urlVideo = urlVideo else {
                        completion(error)
                        return
                    }
                    self.uploadImageToStorage(with: thumb) { url, err in
                        guard let url = url, err == nil else {
                            completion(err)
                            return
                        }
                        FirebaseManager.shared.updateImageMessage(messRef: messRef, images: [], videoURL: "\(urlVideo)", thumbVideo: "\(url)") { err in
                            guard err == nil else {
                                completion(err)
                                return
                            }
                            print("video: ", url)
                            
                            completion(nil)
                        }
                    }
                }
            })
            uploadTask.observe(.progress) { snapshot in
                let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
                self.updateProgress(messRef: messRef, value: percentComplete)
            }
        }catch let error {
            print(error.localizedDescription)
        }
    }
    
    func uploadFile(messRef:DocumentReference, fileURL: URL, completion: @escaping(Error?)-> Void) {
         guard let fileData = try? Data(contentsOf: fileURL) else {
             print("Failed to convert file to data")
             completion(NSError(domain: "com.example.error", code: 0, userInfo: [NSLocalizedDescriptionKey: "Don't get data from URL"]))
             return
         }
         let storageRef = storage.child("documents/\(fileURL)")
         let uploadTask = storageRef.putData(fileData, metadata: nil) { (metadata, error) in
             guard error == nil else {
                 completion(error)
                 return
             }
             // Handle the upload success
             print("File uploaded successfully")
             // You can also get the download URL of the uploaded file from the metadata
             storageRef.downloadURL { url, err in
                 guard let url = url, err == nil else {
                     completion(err)
                     return
                 }
                 self.updateFileMessage(messRef: messRef, fileURL: "\(url)") { er in
                     completion(er)
                 }
                 print((url))
             }
         }
        uploadTask.observe(.progress) { snapshot in
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
            self.updateProgress(messRef: messRef, value: percentComplete)
        }
     }
    
    func updateProgress(messRef: DocumentReference, value: Double) {
        messRef.updateData(["progress": value])
    }
    
    func updateUserActive(isActive: Bool, completion: @escaping(Error?)->Void) {
        let uid = UserDefaultManager.shared.getID()
        print("HI")
        let ref = db.collection(usersCollection).document(uid)
        ref.updateData([
            "isActive": isActive
        ]) { err in
            guard err == nil else {
                completion(err)
                print("eee")
                return
            }
            print("OKE")
            completion(nil)
        }
    }
    
    func logOut(completion: @escaping (Error?) -> Void) {
        self.updateUserActive(isActive: false, completion: { error in
            guard error == nil else {
                completion(error)
                return
            }
            UserDefaultManager.shared.updateIDWhenLogOut()
            completion(nil)
        })
    }
}
