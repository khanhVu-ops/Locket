//
//  CustomHeaderView.swift
//  VideoChatApp
//
//  Created by Khanh Vu on 08/05/5 Reiwa.
//

import UIKit
import SnapKit

class CustomHeaderView: UIView {
    private lazy var lbTitleHeader: UILabel = {
        let lb = UILabel()
        lb.textColor = .black.withAlphaComponent(0.8)
        lb.font = UIFont.systemFont(ofSize: 16)
        lb.backgroundColor = .lightGray.withAlphaComponent(0.5)
        lb.textAlignment = .center
        lb.addConnerRadius(radius: 10)
        return lb
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
   override init(frame: CGRect) {
        super.init(frame: frame)
        configView()
    }
    
    func configView() {
        self.addSubview(lbTitleHeader)
        lbTitleHeader.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(2)
        }
    }
    
    func setTitle(title: String) {
        self.lbTitleHeader.text = " " + title + "  "
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
