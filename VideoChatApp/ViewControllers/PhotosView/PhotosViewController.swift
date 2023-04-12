//
//  PhotosViewController.swift
//  VideoChatApp
//
//  Created by Khanh Vu on 04/04/5 Reiwa.
//

import UIKit
import Photos
import SnapKit
import RxSwift
import RxCocoa
protocol PhotosDelegate: AnyObject {
    func didTapSendImage(assets: [AssetModel])
}

class PhotosViewController: UIViewController {
    
    private lazy var cltvPhotos: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let cltv = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        cltv.backgroundColor = .white
        cltv.allowsMultipleSelection = true
        cltv.register(PhotosCollectionViewCell.self, forCellWithReuseIdentifier: "PhotosCollectionViewCell")
        return cltv
    }()
    
    private lazy var btnCancel: UIButton = {
        let btn = UIButton()
        btn.setTitle("Cancel", for: .normal)
        btn.setTitleColor(.blue, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        btn.addTarget(self, action: #selector(btnCancelTapped), for: .touchUpInside)
        return btn
    }()
    
    private lazy var btnSave: UIButton = {
        let btn = UIButton()
        btn.setTitle("Send", for: .normal)
        btn.setTitleColor(.blue, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        btn.addTarget(self, action: #selector(btnSaveTapped), for: .touchUpInside)
        return btn
    }()
    
    private lazy var lbTotalPhotos: UILabel = {
        let lb = UILabel()
        lb.text = "400"
        lb.textAlignment = .center
        lb.textColor = .blue
        lb.font = UIFont.systemFont(ofSize: 17)
        return lb
    }()
    
    private lazy var stvTop: UIStackView = {
        let stv = UIStackView()
        [btnCancel, lbTotalPhotos, btnSave].forEach { sub in
            stv.addArrangedSubview(sub)
        }
        stv.distribution = .fillEqually
        stv.alignment = .center
        stv.axis = .horizontal
        stv.spacing = 20
        return stv
    }()
    
    let photoViewModel = PhotosViewModel()
    let disposeBag = DisposeBag()
    weak var delegate: PhotosDelegate?
    weak var chatVC: ChatViewController?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestPermission()
        setUpView()
        bindingToViewModel()
    }
    
    func setUpView() {
        self.view.backgroundColor = .white
        [stvTop, cltvPhotos].forEach { sub in
            self.view.addSubview(sub)
        }
        
        self.stvTop.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(40)
        }
        
        self.cltvPhotos.snp.makeConstraints { make in
            make.top.equalTo(self.stvTop.snp.bottom)
            make.leading.trailing.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    
    private func requestPermission() {
        self.requestPermissionAccessPhotos { [weak self] isEnable in
            if isEnable {
                self?.photoViewModel.fetchAssets()
            } else {
                DispatchQueue.main.async {
                    self?.dismiss(animated: true, completion: {
                        self?.showAlertOpenSettingPhotos()
                    })
                }
            }
        }
    }
    
    func bindingToViewModel() {
        self.photoViewModel.assetsBehavior
            .bind(to: self.cltvPhotos.rx.items(cellIdentifier: "PhotosCollectionViewCell", cellType: PhotosCollectionViewCell.self)) { [weak self] index, value , cell in
                cell.configure(viewModel: self?.photoViewModel, item: value, index: index)
            }
            .disposed(by: disposeBag)

        self.cltvPhotos.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        self.photoViewModel.assetsBehavior
            .subscribe(onNext: { [weak self] value in
                self?.lbTotalPhotos.text = "\(value.count)"
            })
            .disposed(by: disposeBag)
    }
    
    @objc func btnCancelTapped(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func btnSaveTapped() {
        self.dismiss(animated: true) {
            self.delegate?.didTapSendImage(assets: self.photoViewModel.getPhotosSelected())
        }
    }
    
}

extension PhotosViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (self.cltvPhotos.frame.width-4)/3, height: (self.cltvPhotos.frame.width-4)/3)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        self.photoViewModel.didSelectItem(index: indexPath.item)
    }
    
}
