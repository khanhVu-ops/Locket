//
//  DetailImageViewController.swift
//  IntergrateMLModel
//
//  Created by Khanh Vu on 07/04/5 Reiwa.
//

import UIKit
import SnapKit
import Photos
import ProgressHUD

class DetailImageView: UIView {

    private lazy var imvDetail: UIImageView = {
        let imv = UIImageView()
        imv.contentMode = .scaleAspectFit
        imv.backgroundColor = .white
        imv.addConnerRadius(radius: 20)
        return imv
    }()
    
    init() {
        super.init(frame: .zero)
        self.setUpView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpView()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setUpView() {
        self.backgroundColor = .clear
        self.addSubview(imvDetail)
        self.imvDetail.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    func setImage(with image: UIImage) {
        self.imvDetail.image = image
    }
}
