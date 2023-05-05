//
//  MessageTableViewCell.swift
//  ChatApp
//
//  Created by Vu Khanh on 16/03/2023.
//

import UIKit
import LinkPresentation
class MessageTableViewCell: UITableViewCell {

    @IBOutlet weak var vMessage: UIView!
    @IBOutlet weak var lbTime: UILabel!
    @IBOutlet weak var tvMessage: UITextView!
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
    
    override func prepareForReuse() {
        self.tvMessage.text = ""
    }
    
    func setUpView() {
        
        self.vMessage.addConnerRadius(radius: 20)
        self.vMessage.addBorder(borderWidth: 1, borderColor: Constants.Color.mainColor)
        self.tvMessage.dataDetectorTypes = [.link, .phoneNumber]
        self.lbTime.backgroundColor = UIColor(hexString: "#F1F1F1")
        self.lbTime.addConnerRadius(radius: 8)
    }
    
    func configure(item: MessageModel) {
        if item.senderID != UserDefaultManager.shared.getID() {
            self.stvMessage.alignment = .leading
            self.vMessage.backgroundColor = .white
            self.tvMessage.textColor = .black
            self.tvMessage.tintColor = .black
        } else {
            self.stvMessage.alignment = .trailing
            self.vMessage.backgroundColor = Constants.Color.mainColor
            self.tvMessage.textColor = .white
            self.tvMessage.tintColor = .white
        }
        self.tvMessage.text = item.message
        let size = tvMessage.sizeThatFits(CGSize(width: tvMessage.frame.width, height: CGFloat.greatestFiniteMagnitude))
        self.lbTime.text = self.convertToString(timestamp: item.created!)
        tvMessage.frame.size.height = size.height
        
        let linkAttributes: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.single.rawValue // Add an underline to the link
        ]
        tvMessage.linkTextAttributes = linkAttributes
    }
}
