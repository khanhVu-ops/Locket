//
//  BaseMessageTableViewCell.swift
//  VideoChatApp
//
//  Created by Khanh Vu on 25/06/5 Reiwa.
//

import UIKit
import SnapKit
class BaseMessageTableViewCell: UITableViewCell {

    lazy var lbTime:  UILabel = {
        let lbTime = UILabel()
        lbTime.textAlignment = .center
        lbTime.backgroundColor = .clear
        return lbTime
    }()
    lazy var lbStatus:  UILabel = {
        let lbStatus = UILabel()
        lbStatus.textAlignment = .center
        lbStatus.backgroundColor = .clear
        return lbStatus
    }()
    
    lazy var vTime:  UIView = {
        let vTime = UIView()
        vTime.addSubview(lbTime)
        vTime.backgroundColor = .clear
        return vTime
    }()
    
    lazy var vStatus:  UIView = {
        let vStatus = UIView()
        vStatus.addSubview(lbStatus)
        vStatus.backgroundColor = .clear
        return vStatus
    }()
    
    lazy var btnReply: UIButton = {
        let btn = UIButton()
//        btn.addTarget(self, action: <#T##Selector#>, for: <#T##UIControl.Event#>)
        return btn
    }()
//    lazy var stvStatus:  UIStackView = {
//        let stvStatus = UIStackView()
//        stvStatus.addArrangedSubview(lbStatus)
//        stvStatus.distribution = .fill
//        stvStatus.axis = .vertical
//        return stvStatus
//    }()
    
    lazy var imvAvata:  UIImageView = {
        let imvAvata = UIImageView()
        imvAvata.contentMode = .scaleAspectFill
        imvAvata.circleClip()
        return imvAvata
    }()
    
    lazy var vContentMessage:  UIView = {
        let vContentMessage = UIView()
        vContentMessage.addConnerRadius(radius: 15)
        vContentMessage.addBorder(borderWidth: 1, borderColor: Constants.Color.mainColor)
        vContentMessage.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapBubble))
        tapGesture.cancelsTouchesInView = false
//        tapGesture.delegate = self
//        tapGesture.delaysTouchesBegan = false
//        tapGesture.delaysTouchesEnded = false
//        vContentMessage.addGestureRecognizer(tapGesture)
        return vContentMessage
    }()
    
    lazy var stvMessage:  UIStackView = {
        let stvMessage = UIStackView()
        stvMessage.addArrangedSubview(vContentMessage)
        stvMessage.distribution = .fill
        stvMessage.alignment = .leading
        stvMessage.spacing = 0
        stvMessage.axis = .vertical
        return stvMessage
    }()
    
    lazy var stvContentMessage:  UIStackView = {
        let stvContentMessage = UIStackView()
        [imvAvata,stvMessage].forEach { sub in
            stvContentMessage.addArrangedSubview(sub)
        }
        stvContentMessage.distribution = .fill
        stvContentMessage.alignment = .bottom
        stvContentMessage.spacing = 8
        stvContentMessage.axis = .horizontal
        return stvContentMessage
    }()
    
    lazy var stvContentCell: UIStackView = {
        let stvContentCell = UIStackView()
        [vTime, stvContentMessage, vStatus].forEach { sub in
            stvContentCell.addArrangedSubview(sub)
        }
        stvContentCell.distribution = .fill
        stvContentCell.alignment = .fill
        stvContentCell.spacing = 0
        stvContentCell.axis = .vertical
        return stvContentCell
    }()
    
    var topStvConstraint: Constraint?
    var widthContentMessageConstraints: Constraint?
    let uid = UserDefaultManager.shared.getID()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setUpView()
        addContentMessage()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpView() {
        self.contentView.addSubview(stvContentCell)
        
        self.contentView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        self.stvContentCell.snp.makeConstraints { make in
            topStvConstraint = make.top.equalToSuperview().offset(5).constraint
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview()
        }
        
        self.lbTime.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-5)
        }
        
        self.lbStatus.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(38) // 25+8+5
            make.trailing.equalToSuperview().offset(-5)
        }
        self.imvAvata.snp.makeConstraints { make in
            make.width.height.equalTo(25)
        }
        self.vContentMessage.snp.makeConstraints { make in
            widthContentMessageConstraints = make.width.equalTo(self.contentView.snp.width).multipliedBy(0.6).constraint
        }
    }
    
    func addContentMessage() {}
    
    func configure(item: MessageModel, user: UserModel, indexPath: IndexPath) {
        self.stvMessage.alignment = item.senderID == uid ? .trailing : .leading
        self.lbStatus.textAlignment = item.senderID == uid ? .right : .left
        self.vContentMessage.backgroundColor = item.senderID == uid ? Constants.Color.mainColor : .white
        self.imvAvata.isHidden = item.senderID == uid ? true : false
        self.imvAvata.setImage(urlString: user.avataURL ?? "", placeHolder: Constants.Image.defaultAvata)
        self.vTime.isHidden = item.isBubble
        self.vStatus.isHidden = item.isBubble
    }
    
    @objc func tapBubble() {}

}
