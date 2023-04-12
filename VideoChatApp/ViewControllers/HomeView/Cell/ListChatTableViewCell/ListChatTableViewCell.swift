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
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setUpView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUpView() {
        self.vBorder.addConnerRadius(radius: 15)
        self.vBorder.addBorder(borderWidth: 2, borderColor: Constants.Color.mainColor)
        
        self.imvAvata.addConnerRadius(radius: self.imvAvata.frame.width/2)
//        self.imvAvata.addBorder(borderWidth: 2, borderColor: UIColor(hexString: "#ff9600"))
        
        self.lbNewMessage.textColor = UIColor(hexString: "#5C5C5C")
        self.lbTime.textColor = UIColor(hexString: "#5C5C5C")
        
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
    }
    
}
