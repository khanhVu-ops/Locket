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
        tvMessage.backgroundColor = .clear
        tvMessage.isEditable = true
        tvMessage.isScrollEnabled = false
        tvMessage.delegate = self
        tvMessage.textContainerInset = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
        return tvMessage
    }()

    var item: MessageModel?
    var indexPath = IndexPath()
    var actionTapBubble: (() -> Void)?

    var isFirstTap = true

    override func prepareForReuse() {
        self.tvMessage.text = ""
    }

    override func setUpView() {
        super.setUpView()
        self.widthContentMessageConstraints?.deactivate()
        self.vContentMessage.addSubview(self.tvMessage)
        self.tvMessage.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
        self.vContentMessage.snp.makeConstraints { make in
            make.width.lessThanOrEqualTo(self.contentView).multipliedBy(0.6)
        }
    }

    override func configure(item: MessageModel, user: UserModel, indexPath: IndexPath) {
        self.indexPath = indexPath
        self.item = item
        self.tvMessage.attributedText = item.senderID == uid ? item.message?.detectAndStyleLinks(foregroundColor: .white, fontSize: 17) : item.message?.detectAndStyleLinks(foregroundColor: .black, fontSize: 17)
        let size = tvMessage.sizeThatFits(CGSize(width: tvMessage.frame.width, height: CGFloat.greatestFiniteMagnitude))
        tvMessage.frame.size.height = size.height
        super.configure(item: item, user: user, indexPath: indexPath)
    }

    func tapBubble() {
        guard let item = item else {
            return
        }
        print("tap bubble")
        item.isBubble.toggle()
        UIView.animate(withDuration: 0.3) {
            self.vContentMessage.backgroundColor = item.isBubble ? self.vContentMessage.backgroundColor?.withAlphaComponent(0.8) : self.vContentMessage.backgroundColor?.withAlphaComponent(1)
            self.vTime.isHidden = item.isBubble
            self.vStatus.isHidden = item.isBubble
            self.lbStatus.text = !item.isBubble ? "sent" : ""
            self.lbTime.text = !item.isBubble ? item.created?.convertTimestampToTimeString() : ""

        }
        UIView.animate(withDuration: 0.5) { 
            self.lbStatus.alpha = !item.isBubble ? 0.8 : 0
            self.lbTime.alpha = !item.isBubble ? 0.8 : 0
        }
        if let actionTapBubble = actionTapBubble {
            actionTapBubble()
        }
        
    }
}
// MARK: TextViewDelegate
extension MessageTextCell: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        tapBubble()
        return false
    }

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return true

    }
}
