//
//  ListChatTableViewCell.swift
//  ChatApp
//
//  Created by Vu Khanh on 06/03/2023.
//

import UIKit
import FirebaseFirestore
import RxSwift
import RxCocoa
class ListChatTableViewCell: UITableViewCell {

    @IBOutlet weak var vBorder: UIView!
    @IBOutlet weak var lbTime: UILabel!
    @IBOutlet weak var lbNewMessage: UILabel!
    @IBOutlet weak var lbUsername: UILabel!
    @IBOutlet weak var imvAvata: UIImageView!
    @IBOutlet weak var vStatusActive: UIView!
    @IBOutlet weak var imvIconNewMessage: UIImageView!
    
    private let colorMessage = UIColor(hexString: "#5C5C5C")
    var actionSelectRow: ((String, String, UserModel) -> Void)?
    var uid2: String?
    var conversationID: String?
    let disposeBag = DisposeBag()
    var user: UserModel?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setUpView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
       
    }
    
    func setUpView() {
        self.vBorder.addConnerRadius(radius: 15)
        self.vBorder.addBorder(borderWidth: 2, borderColor: Constants.Color.mainColor)
        self.imvAvata.addConnerRadius(radius: self.imvAvata.frame.width/2)
        self.lbNewMessage.textColor = self.colorMessage
        self.lbTime.textColor = self.colorMessage
        self.imvIconNewMessage.isHidden = true
        self.vStatusActive.circleClip()
        self.vStatusActive.addBorder(borderWidth: 1, borderColor: .white)
    }
    
    func configure(viewModel: HomeViewModel, item: ConverationModel) {
        guard let uid = UserDefaultManager.shared.getID() else {
            return
        }
        self.uid2 = item.uid2
        self.conversationID = item.conversationID
        self.user = viewModel.getUserLocalFromUID(uid: item.uid2)
        self.lbUsername.text = user?.username
        self.imvAvata.setImage(urlString: user?.avataURL ?? "", placeHolder: Constants.Image.defaultAvata)
        self.vStatusActive.backgroundColor = (user?.isActive == true) ? .green : .gray
        var txt = ""
        txt = item.lastSenderID == uid ? "You: " : ""
        switch item.lastMessageType {
        case .text:
            txt += item.lastMessage ?? "sent text" + "."
        case .image:
            txt += "sent image."
        case .audio:
            txt += "sent audio."
        case .video:
            txt += "sent video."
        case .file:
            txt += "sent file."
        case .none:
            break
        }
        self.lbNewMessage.text = txt
        self.lbTime.text = Utilitis.shared.convertToString(timestamp: item.lastCreated ?? Timestamp(date: Date()))
        self.updatText(unreadNumber: getUnreadNumber(item: item, uid: uid))
        
        
    }
    

    
    func updatText(unreadNumber: Int) {
        lbUsername.font = unreadNumber > 0 ? UIFont.boldSystemFont(ofSize: 20) : UIFont.systemFont(ofSize: 17, weight: .medium)
        lbNewMessage.font = unreadNumber > 0 ? UIFont.boldSystemFont(ofSize: 15) : UIFont.systemFont(ofSize: 13)
        lbNewMessage.textColor = unreadNumber > 0 ? .black : self.colorMessage
        self.imvIconNewMessage.isHidden = !(unreadNumber > 0)
    }
    
    func getUnreadNumber(item: ConverationModel, uid: String) -> Int {
        guard let users = item.users,
              let unreadArray = item.unreadArray else {
            return 0
        }
        var unread = 0
        for (index, value) in users.enumerated() {
            if value == uid {
                unread = unreadArray[index]
            }
        }
        return unread
    }
    
    @IBAction func btnSelectRowTapped(_ sender: Any) {
        guard let uid2 = uid2, let user = user,  let conversationID = conversationID, let actionSelectRow = actionSelectRow else {
            return
        }
        actionSelectRow(conversationID, uid2, user)
    }
}
