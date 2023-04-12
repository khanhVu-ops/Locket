//
//  PhotosCollectionViewCell.swift
//  VideoChatApp
//
//  Created by Khanh Vu on 04/04/5 Reiwa.
//

import UIKit
import SnapKit
class PhotosCollectionViewCell: UICollectionViewCell {
    
    private lazy var imv: UIImageView = {
        let imv = UIImageView()
        imv.contentMode = .scaleAspectFill
        return imv
    }()
    private lazy var btnSelection: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "checkmark.circle"), for: .normal)
        btn.tintColor = .systemBlue
        btn.addTarget(self, action: #selector(btnSelectionTapped), for: .touchUpInside)
        return btn
    }()
    
    private lazy var lbDuration: UILabel = {
        let lb = UILabel()
        lb.textColor = .white
        lb.font = UIFont.systemFont(ofSize: 17)
        lb.textAlignment = .right
        return lb
    }()
    
    var photoViewModel: PhotosViewModel?
    var index: Int?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUpView()
    }
    
    override func prepareForReuse() {
        self.photoViewModel = nil
    }
    
    
    func setUpView() {
        [imv, btnSelection, lbDuration].forEach { sub in
            self.addSubview(sub)
        }
        btnSelection.isHidden = true
        
        self.imv.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview()
        }
        self.btnSelection.snp.makeConstraints { make in
            make.width.height.equalTo(40)
            make.top.trailing.equalToSuperview().inset(5)
        }
        self.lbDuration.snp.makeConstraints { make in
            make.trailing.bottom.equalToSuperview().inset(8)
        }
    }
    
    func configure(viewModel: PhotosViewModel?,item: AssetModel, index: Int) {
        self.photoViewModel = viewModel
        self.index = index
        self.imv.image = item.thumbnail
        self.btnSelection.isHidden = !item.isSelected

        if item.duration > 0 {
            let minutes = Int(item.duration / 60)
            let seconds = Int(item.duration.truncatingRemainder(dividingBy: 60))
            self.lbDuration.text = String(format: "%02d:%02d", minutes, seconds)
            self.lbDuration.isHidden = false
        } else {
            self.lbDuration.isHidden = true
        }
    }
    
    @objc func btnSelectionTapped() {
        guard let viewModel = photoViewModel, let index = index else {
            return
        }
        viewModel.didSelectItem(index: index)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
