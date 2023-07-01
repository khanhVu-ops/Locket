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
//protocol PhotosDelegate: AnyObject {
//    func didTapSendImage(assets: [AssetModel])
//}

class PhotosViewController: UIViewController {
    
    private lazy var cltvPhotos: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 2
        layout.itemSize = CGSize(width: (view.frame.width-4)/3, height: (view.frame.width-4)/3)
        let cltv = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        cltv.backgroundColor = .green
        cltv.allowsMultipleSelection = true
        cltv.register(PhotosCollectionViewCell.self, forCellWithReuseIdentifier: PhotosCollectionViewCell.nibNameClass)
        
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
    
    var actionSendAsset: (([MediaModel]) -> Void)?
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
                    self?.showAlertOpenSettingPhotos()
                }
            }
        }
    }
    
    func bindingToViewModel() {
        self.photoViewModel.assetsBehavior
            .bind(to: self.cltvPhotos.rx.items(cellIdentifier: PhotosCollectionViewCell.nibNameClass, cellType: PhotosCollectionViewCell.self)) { [weak self] index, media , cell in
                guard let self = self, let asset = media.asset else {
                    return
                }
                media.ratio = asset.getImageAspectRatio() ?? 1
                if media.type == .image {
                    cell.setUpImage(asset: asset)
                    asset.getFullSizeImageURL(completion: { [weak self] url in
                        guard let self = self, let url = url else {
                            return
                        }
                        media.filePath = url
                        print(url)
                        media.duration = 0
//                        self.photoViewModel.deleteFile(at: url)
                    })
                } else if media.type == .video {
                    asset.avAsset { [weak cell] avAsset in
                        if let avAsset =  avAsset {
                            let thumbnail = Video.shared.getThumbnailImageLocal(asset: avAsset)
                            let duration = avAsset.duration.seconds
                            media.filePath = avAsset.url
                            media.thumbnail = thumbnail
                            media.duration = duration
                            cell?.setupVideo(image: thumbnail, duration: duration)
                            
                        }
                    }
                }
                
                cell.isSelect = media.isSelect
                cell.actionSelect = {[weak self, weak cell]  in
                    guard let self = self, let cell = cell else { return }
                    media.isSelect = !media.isSelect
                    cell.isSelect = media.isSelect
                    guard self.photoViewModel.validate(type: media.type ?? .image, isSelect: media.isSelect) else {
                        cell.isSelect = false
                        return
                    }
                    if cell.isSelect {
                        self.photoViewModel.mediaSelect.appendUnduplicate(object: media)
                        print(media.filePath)
                    } else {
                        self.photoViewModel.mediaSelect.remove(object: media)
                    }
                }
                cell.actionPreviewImage = {[weak self] in
                    guard let self = self else { return }
//                    self.previewMedia(data: self.images, index: indexPath.row, type: .ChatSend)
                }
            }
            .disposed(by: disposeBag)

        self.photoViewModel.assetsBehavior
            .subscribe(onNext: { [weak self] value in
                self?.lbTotalPhotos.text = "\(value.count)"
            })
            .disposed(by: disposeBag)
        
        self.photoViewModel.mediaSelectObservable
            .map({$0.isEmpty})
            .bind(to: self.btnSave.rx.isHidden)
            .disposed(by: disposeBag)
    }
    
    @objc func btnCancelTapped(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func btnSaveTapped() {
        if let actionSendAsset = self.actionSendAsset {
            actionSendAsset(self.photoViewModel.mediaSelect)
        }
        self.dismiss(animated: true)
    }
    
}
