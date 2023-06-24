//
//  BaseMessageTableViewCell.swift
//  VideoChatApp
//
//  Created by Khanh Vu on 24/06/5 Reiwa.
//

import UIKit
import SnapKit
class BaseMessageTableViewCell: UITableViewCell {

    @IBOutlet weak var lbTime: UILabel!
    @IBOutlet weak var lbStatus: UILabel!
    @IBOutlet weak var imvAvata: UIImageView!
    @IBOutlet weak var vContentMessage: UIView!
    @IBOutlet weak var stvMessage: UIStackView!
    
    let uid = UserDefaultManager.shared.getID()
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setUpView()
        self.addContentMessage()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUpView() {
        self.vContentMessage.addConnerRadius(radius: 15)
        self.vContentMessage.addBorder(borderWidth: 1, borderColor: Constants.Color.mainColor)
        
        self.imvAvata.circleClip()
    }
    
    func addContentMessage() {}
    
    func configure(item: MessageModel) {
        self.stvMessage.alignment = item.senderID == uid ? .trailing : .leading
        self.vContentMessage.backgroundColor = item.senderID == uid ? Constants.Color.mainColor : .white
        self.imvAvata.isHidden = item.senderID == uid ? true : false
        self.lbTime.text = Utilitis.shared.convertToString(timestamp: item.created!)
    }
}
