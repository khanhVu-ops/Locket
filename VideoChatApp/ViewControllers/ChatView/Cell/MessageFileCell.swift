//
//  MessageFileCell.swift
//  VideoChatApp
//
//  Created by Khanh Vu on 05/07/5 Reiwa.
//

import Foundation
import UIKit
import SnapKit

class MessageFileCell: BaseMessageTableViewCell {
    private lazy var imvIconFile: UIImageView = {
        let imv = UIImageView()
        imv.image = UIImage(named: "ic_file")
        return imv
    }()
    
    private lazy var lbFileName: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 16)
        lb.textColor = .black
        lb.numberOfLines = 2
        lb.textAlignment = .left
        lb.lineBreakMode = .byTruncatingMiddle
        return lb
    }()
    
    private lazy var lbFileSize: UILabel = {
        let lb = UILabel()
        lb.font = UIFont.systemFont(ofSize: 12)
        lb.textColor = .black.withAlphaComponent(0.7)
        lb.numberOfLines = 1
        lb.textAlignment = .left
        return lb
    }()
    
    private lazy var stvLbFile: UIStackView = {
        let stv = UIStackView()
        [lbFileName, lbFileSize].forEach { sub in
            stv.addArrangedSubview(sub)
        }
        stv.axis = .vertical
        stv.distribution = .fill
        stv.alignment = .fill
        stv.spacing = 2
        return stv
    }()
    
    private lazy var btnOpenFile: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .clear
        btn.addTarget(self, action: #selector(tapOpenFile), for: .touchUpInside)
        return btn
    }()
    
    var fileURL: URL?
    var actionOpenFile: ((URL) -> Void)?
    override func prepareForReuse() {
        self.lbFileName.text = nil
        self.lbFileSize.text = nil
    }
    
    override func setUpView() {
        super.setUpView()
        
        [imvIconFile, stvLbFile, btnOpenFile].forEach { sub in
            self.vContentMessage.addSubview(sub)
        }
        
        imvIconFile.snp.makeConstraints { make in
            make.width.height.equalTo(40)
            make.leading.equalToSuperview().offset(15)
            make.top.bottom.equalToSuperview().inset(10)
        }
        
        stvLbFile.snp.makeConstraints { make in
            make.leading.equalTo(imvIconFile.snp.trailing).offset(5)
            make.trailing.equalToSuperview().offset(-10)
            make.centerY.equalTo(self.imvIconFile)

        }
        
        btnOpenFile.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
        
        self.vContentMessage.snp.makeConstraints { make in
            make.width.lessThanOrEqualTo(self).multipliedBy(0.65)
        }
        
        imvIconFile.circleClip()
    }
    
    override func configure(item: MessageModel, user: UserModel, indexPath: IndexPath) {
        super.configure(item: item, user: user, indexPath: indexPath)
        guard let fileURL = URL(string: item.fileURL ?? "") else {
            return
        }
        self.fileURL = fileURL
        self.lbFileName.text = item.fileName
        self.lbFileSize.text = "\((item.duration ?? 0.0).rounded(toPlaces: 2)) Mb"
    }
    
    @objc func tapOpenFile() {
        guard let fileURL = fileURL, let actionOpenFile = actionOpenFile else {
            return
        }
        actionOpenFile(fileURL)

    }
}
