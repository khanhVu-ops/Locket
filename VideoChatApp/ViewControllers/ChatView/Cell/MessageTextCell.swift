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
        let size = tvMessage.getSize()
        tvMessage.frame.size.height = size.height
        super.configure(item: item, user: user, indexPath: indexPath)
    }

    func tapBubble() {
        guard let item = item else {
            return
        }
        print("tap bubble")
        item.isBubble.toggle()
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else {
                return
            }
            self.vTime.isHidden = item.isShowTime ? false : !item.isBubble
            if item.senderID == self.uid {
                self.vContentMessage.backgroundColor = !item.isBubble ? Constants.Color.mainColor : Constants.Color.tapBubleColor
                self.vStatus.isHidden = item.isShowStatus ? false : !item.isBubble
            } else {
                self.vStatus.isHidden = true
            }
            UIView.animate(withDuration: 0.5) { [weak self] in
                guard let self = self else {
                    return
                }
                self.lbStatus.alpha = self.vStatus.isHidden ? 0 : 0.8
                self.lbTime.alpha = self.vTime.isHidden ? 0 : 0.8
            }
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
