//
//  MessageTableViewCell.swift
//  ChatApp
//
//  Created by Vu Khanh on 16/03/2023.
//

import UIKit

class MessageTableViewCell: UITableViewCell {

    @IBOutlet weak var vMessage: UIView!
    @IBOutlet weak var lbTime: UILabel!
    @IBOutlet weak var lbMessage: UILabel!
    @IBOutlet weak var stvMessage: UIStackView!
    override func awakeFromNib() {
        super.awakeFromNib()
        setUpView()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setUpView() {
        self.vMessage.addConnerRadius(radius: 20)
        self.vMessage.addBorder(borderWidth: 1, borderColor: Constants.Color.mainColor)
        
        self.lbTime.backgroundColor = UIColor(hexString: "#F1F1F1")
        self.lbTime.addConnerRadius(radius: 8)
    }
    
    func configure(item: MessageModel) {
        if item.senderID != UserDefaultManager.shared.getID() {
            self.stvMessage.alignment = .leading
            self.vMessage.backgroundColor = .white
            self.lbMessage.textColor = .black
        } else {
            self.stvMessage.alignment = .trailing
            self.vMessage.backgroundColor = Constants.Color.mainColor
            self.lbMessage.textColor = .white
        }
        self.lbMessage.text = item.message
        self.lbTime.text = self.convertToString(timestamp: item.created!)
        
    }
    
}
