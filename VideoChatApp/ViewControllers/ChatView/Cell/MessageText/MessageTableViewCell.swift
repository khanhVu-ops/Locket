//
//  MessageTableViewCell.swift
//  ChatApp
//
//  Created by Vu Khanh on 16/03/2023.
//

import UIKit
import LinkPresentation
import SnapKit

protocol BubleTextMessageDelegate {
    func didTapBubbleMessage(indexPath: IndexPath)
}

class MessageTextCell: BaseMessageTableViewCell {

    private lazy var tvMessage: UITextView = {
        let tvMessage = UITextView()
        tvMessage.backgroundColor = .clear
        tvMessage.font = UIFont.systemFont(ofSize: 17)
        tvMessage.isEditable = false
        tvMessage.isScrollEnabled = false
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapBubble))
        tapGesture.cancelsTouchesInView = false
//        tapGesture.delegate = self
//        tapGesture.delaysTouchesBegan = false
//        tapGesture.delaysTouchesEnded = false
        tvMessage.addGestureRecognizer(tapGesture)
//        tvMessage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapBubble)))
        return tvMessage
    }()
    
    private lazy var btnBubble: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .clear
//        btn.addTarget(self, action:  #selector(tapBubble), for: .touchUpInside)
        return btn
    }()
    
    var item: MessageModel?
    var indexPath = IndexPath()
    var delegate: BubleTextMessageDelegate?
    override func prepareForReuse() {
        self.tvMessage.text = ""
    }
    
    override func addContentMessage() {
        self.widthContentMessageConstraints?.deactivate()
        self.vContentMessage.addSubview(self.tvMessage)
//        self.vContentMessage.addSubview(self.btnBubble)

        self.tvMessage.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(10)
        }
        
//        self.btnBubble.snp.makeConstraints { make in
//            make.top.bottom.leading.trailing.equalToSuperview()
//        }
        self.vContentMessage.snp.makeConstraints { make in
            make.width.lessThanOrEqualTo(self.contentView).multipliedBy(0.6)
        }
        self.tvMessage.dataDetectorTypes = [.link, .phoneNumber]
        
    }
    
    override func configure(item: MessageModel, user: UserModel, indexPath: IndexPath) {
        super.configure(item: item, user: user, indexPath: indexPath)
        self.indexPath = indexPath
        self.item = item
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
    
    @objc override func tapBubble() {
        guard let item = item else {
            return
        }
        print("tap bubble")
        item.isBubble.toggle()
        UIView.animate(withDuration: 0.3) {
            self.vTime.isHidden = item.isBubble
            self.vStatus.isHidden = item.isBubble
            self.lbStatus.text = !item.isBubble ? "sent" : ""
            self.lbTime.text = !item.isBubble ? Utilitis.shared.convertToString(timestamp: item.created!) : ""

        }
        UIView.animate(withDuration: 0.5) {
            self.lbStatus.alpha = !item.isBubble ? 0.8 : 0
            self.lbTime.alpha = !item.isBubble ? 0.8 : 0
        }
        
        self.delegate?.didTapBubbleMessage(indexPath: self.indexPath)
//        layoutIfNeeded()
    }
}
