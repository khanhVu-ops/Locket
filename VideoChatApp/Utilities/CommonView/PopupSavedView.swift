//
//  PopupSavedView.swift
//  VideoChatApp
//
//  Created by Khanh Vu on 08/05/5 Reiwa.
//

import UIKit
import SnapKit

class PopupSavedView: UIView {
    var popupWidth = 120
    private lazy var imvCheckMark: UIImageView = {
        let imv = UIImageView()
        imv.image = UIImage(systemName: "checkmark")
        imv.tintColor = .black.withAlphaComponent(0.6)
        return imv
    }()
    
    private lazy var lbSaved: UILabel = {
        let lb = UILabel()
        lb.text = "Saved"
        lb.textColor = .black.withAlphaComponent(0.6)
        lb.textAlignment = .center
        lb.font = UIFont.boldSystemFont(ofSize: 17)
        return lb
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        super.init(frame: .zero)
        configView()
    }
    
    func configView() {
        self.backgroundColor = .white.withAlphaComponent(0.8)
        [imvCheckMark, lbSaved].forEach { sub in
            self.addSubview(sub)
        }
        self.addConnerRadius(radius: 10)
        self.imvCheckMark.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-20)
            make.width.height.equalTo(60)
        }
        self.lbSaved.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.imvCheckMark.snp.bottom).offset(5)
            make.width.equalTo(100)
        }
    }

}
