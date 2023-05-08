//
//  ListChatTableViewCell.swift
//  ChatApp
//
//  Created by Vu Khanh on 06/03/2023.
//

import UIKit
import FirebaseFirestore
class ListChatTableViewCell: UITableViewCell {

    @IBOutlet weak var vBorder: UIView!
    @IBOutlet weak var lbTime: UILabel!
    @IBOutlet weak var lbNewMessage: UILabel!
    @IBOutlet weak var lbUsername: UILabel!
    @IBOutlet weak var imvAvata: UIImageView!
    @IBOutlet weak var lbBadgeMessage: UILabel!
    private let colorMessage = UIColor(hexString: "#5C5C5C")
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
        self.lbBadgeMessage.textColor = .white
        self.lbBadgeMessage.backgroundColor = .red
        self.lbBadgeMessage.font = UIFont.boldSystemFont(ofSize: 13)
        self.lbBadgeMessage.addConnerRadius(radius: self.lbBadgeMessage.frame.width/2)
        self.lbBadgeMessage.isHidden = true
    }
    
    func configure(item: ChatModel) {
        if let url = URL(string: item.roomURL ?? "") {
            self.imvAvata.sd_setImage(with: url, placeholderImage: UIImage(systemName: "person.fill"))
        } else {
            self.imvAvata.image = Constants.Image.defaultAvata
        }
        var txt = ""
        if item.lastSenderID == UserDefaultManager.shared.getID() {
            txt = "You: "
        } else {
            txt = item.roomName!.components(separatedBy: " ")[0] + ": "
        }
        if item.lastMessage == "" {
            txt += "sent image."
        } else {
            txt += item.lastMessage!
        }
        self.lbNewMessage.text = txt
        self.lbUsername.text = item.roomName
        self.lbTime.text = self.convertToString(timestamp: item.lastCreated ?? Timestamp(date: Date()))
        self.changeBoldText(item: item)
    }
    
    private func changeBoldText(item: ChatModel) {
        guard let unreadCount = item.unreadCount, let usersID = item.users else {
            return
        }
        var unreadNunber = 0
        for (index, value) in usersID.enumerated() {
            if value == UserDefaultManager.shared.getID() {
                unreadNunber = unreadCount[index]
                break
            }
        }
        if unreadNunber > 0 {
            lbUsername.font = UIFont.boldSystemFont(ofSize: 20)
            lbNewMessage.font = UIFont.boldSystemFont(ofSize: 15)
            lbNewMessage.textColor = .black
            self.lbBadgeMessage.isHidden = false
            self.lbBadgeMessage.text = "\(unreadNunber)"
        } else {
            lbUsername.font = UIFont.systemFont(ofSize: 17, weight: .medium)
            lbNewMessage.font = UIFont.systemFont(ofSize: 13)
            lbNewMessage.textColor = self.colorMessage
            self.lbBadgeMessage.isHidden = true
        }
    }
    
}
