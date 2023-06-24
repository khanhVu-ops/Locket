//
//  MessageTableViewCell.swift
//  ChatApp
//
//  Created by Vu Khanh on 16/03/2023.
//

import UIKit
import LinkPresentation
import SnapKit

class MessageTextCell: BaseMessageTableViewCell {

    private lazy var tvMessage: UITextView = {
        let tvMessage = UITextView()
        return tvMessage
    }()
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
    
    override func addContentMessage() {
        self.vContentMessage.addSubview(self.tvMessage)
        self.tvMessage.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(5)
            make.leading.trailing.equalToSuperview().inset(15)
        }
        self.tvMessage.dataDetectorTypes = [.link, .phoneNumber]
    }
    
    override func configure(item: MessageModel) {
        self.tvMessage.textColor = item.senderID == uid ? .white : .black
        self.tvMessage.tintColor = item.senderID == uid ? .white : .black
        self.tvMessage.text = item.message
        let size = tvMessage.sizeThatFits(CGSize(width: tvMessage.frame.width, height: CGFloat.greatestFiniteMagnitude))
        tvMessage.frame.size.height = size.height
        
        let linkAttributes: [NSAttributedString.Key: Any] = [
            .underlineStyle: NSUnderlineStyle.single.rawValue // Add an underline to the link
        ]
        tvMessage.linkTextAttributes = linkAttributes
    }
}
