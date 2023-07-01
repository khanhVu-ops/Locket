//
//  PhotosCollectionViewCell.swift
//  VideoChatApp
//
//  Created by Khanh Vu on 04/04/5 Reiwa.
//

import UIKit
import SnapKit
import Photos
class PhotosCollectionViewCell: UICollectionViewCell {
    
    private lazy var imv: UIImageView = {
        let imv = UIImageView()
        imv.contentMode = .scaleAspectFill
        return imv
    }()
    private lazy var btnSelection: UIButton = {
        let btn = UIButton(type: .system)
        btn.backgroundColor = .clear
        btn.addTarget(self, action: #selector(btnSelectionTapped), for: .touchUpInside)
        return btn
    }()
    
    private lazy var imvCheckMark: UIImageView = {
        let imv = UIImageView()
        imv.contentMode = .scaleAspectFill
        imv.image = UIImage(systemName: "checkmark.circle")
        imv.tintColor = .systemBlue
        return imv
    }()
    private lazy var lbDuration: UILabel = {
        let lb = UILabel()
        lb.textColor = .white
        lb.font = UIFont.systemFont(ofSize: 17)
        lb.textAlignment = .right
        return lb
    }()
    
    var media: MediaModel = MediaModel()
    var actionSelect: (() -> Void)?
    var actionPreviewImage: (() -> Void)?
    var isSelect: Bool = false {
        didSet {
            imvCheckMark.isHidden = !isSelect
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpView()
    }
    
    override func prepareForReuse() {
//        self.photoViewModel = nil
    }
    
    
    func setUpView() {
        [imv, imvCheckMark, lbDuration, btnSelection].forEach { sub in
            self.addSubview(sub)
        }
        self.clipsToBounds = true
        
        self.imv.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
        self.imvCheckMark.snp.makeConstraints { make in
            make.width.height.equalTo(25)
            make.top.trailing.equalToSuperview().inset(5)
        }
        self.lbDuration.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview().inset(8)
        }
        
        self.btnSelection.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        self.addGestureRecognizer(longPressGesture)
    }
    
    func setUpImage(asset: PHAsset) {
        asset.image(targetSize: CGSize(width: 250, height: 250)) { image in
            DispatchQueue.main.async {
                self.imv.image = image
                self.lbDuration.isHidden = true
            }
        }
    }
    
    func setupVideo(image: UIImage?, duration: Double) {        
        DispatchQueue.main.async {
            self.imv.image = image
            self.lbDuration.isHidden = false
            self.lbDuration.text = Video.shared.formatTimeVideo(time: Int(duration))
        }
    }
    
    @objc func btnSelectionTapped() {
        if let btnAction = self.actionSelect {
            btnAction()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            if let action = actionPreviewImage{
                action()
            }
        }
    }
    
//    func configure(viewModel: PhotosViewModel?,item: AssetModel, index: Int) {
//        self.photoViewModel = viewModel
//        self.index = index
//        self.imv.image = item.thumbnail
//        self.btnSelection.isHidden = !item.isSelected
//
//        if item.duration > 0 {
//            let minutes = Int(item.duration / 60)
//            let seconds = Int(item.duration.truncatingRemainder(dividingBy: 60))
//            self.lbDuration.text = String(format: "%02d:%02d", minutes, seconds)
//            self.lbDuration.isHidden = false
//        } else {
//            self.lbDuration.isHidden = true
//        }
//    }
    
    
}
