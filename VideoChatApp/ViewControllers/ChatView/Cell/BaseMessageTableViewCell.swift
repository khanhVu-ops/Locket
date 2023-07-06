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
        lbTime.font = UIFont.systemFont(ofSize: 12)
        return lbTime
    }()
    lazy var lbStatus:  UILabel = {
        let lbStatus = UILabel()
        lbStatus.textAlignment = .center
        lbStatus.backgroundColor = .clear
        lbStatus.font = UIFont.systemFont(ofSize: 12)
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
        return btn
    }()
    
    lazy var imvAvata:  UIImageView = {
        let imvAvata = UIImageView()
        imvAvata.contentMode = .scaleAspectFill
        imvAvata.circleClip()
        return imvAvata
    }()
    
    lazy var vContentMessage:  UIView = {
        let vContentMessage = UIView()
        vContentMessage.addConnerRadius(radius: 18)
        return vContentMessage
    }()
    
    lazy var stvMessage:  UIStackView = {
        let stvMessage = UIStackView()
        stvMessage.addArrangedSubview(vContentMessage)
        stvMessage.distribution = .fill
        stvMessage.alignment = .trailing
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
    let uid = UserDefaultManager.shared.getID()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setUpView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
    }
    
    func setUpView() {
        self.contentView.addSubview(stvContentCell)
        UIView.performWithoutAnimation { [weak self] in
            guard let self = self else {
                return
            }
            self.contentView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)

        }
        self.stvContentCell.snp.makeConstraints { make in
            topStvConstraint = make.top.equalToSuperview().offset(5).constraint
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview()
        }
        
        self.lbTime.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.centerX.equalTo(vTime)
            make.bottom.equalToSuperview().offset(-5)
        }
        
        self.lbStatus.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(5)
            make.leading.equalToSuperview().offset(38) // 25+8+5
            make.trailing.equalToSuperview().offset(-5)
        }
        self.imvAvata.snp.makeConstraints { make in
            make.width.height.equalTo(25)
        }
    }
    func configure(item: MessageModel, user: UserModel, indexPath: IndexPath) {
        UIView.performWithoutAnimation { [weak self] in
            guard let self = self else {
                return
            }
            self.stvMessage.alignment = item.senderID == uid ? .trailing : .leading
            self.lbStatus.textAlignment = item.senderID == uid ? .right : .left
            self.vContentMessage.backgroundColor = item.senderID == uid ? Constants.Color.mainColor : .gray.withAlphaComponent(0.2)
            self.imvAvata.isHidden = item.senderID == uid ? true : false
            self.imvAvata.setImage(urlString: user.avataURL ?? "", placeHolder: Constants.Image.defaultAvata)
            self.vTime.isHidden = !item.isBubble
            self.lbTime.text = item.created?.convertTimestampToTimeString()
            self.vStatus.isHidden = !item.isBubble
            self.lbStatus.text = item.status.rawValue
        }
    }
}
