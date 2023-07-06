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
        cltv.allowsMultipleSelection = true
        cltv.register(PhotosCollectionViewCell.self, forCellWithReuseIdentifier: PhotosCollectionViewCell.nibNameClass)
        
        return cltv
    }()
    
    private lazy var btnCancel: UIButton = {
        let btn = UIButton()
        btn.setTitle("Cancel", for: .normal)
        btn.setTitleColor(.blue, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        btn.addTarget(self, action: #selector(btnCancelTapped), for: .touchUpInside)
        return btn
    }()
    
    private lazy var btnSave: UIButton = {
        let btn = UIButton()
        btn.setTitle("Send", for: .normal)
        btn.setTitleColor(.blue, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        btn.addTarget(self, action: #selector(btnSaveTapped), for: .touchUpInside)
        return btn
    }()
    
    private lazy var lbTotalPhotos: UILabel = {
        let lb = UILabel()
        lb.text = "total 400"
        lb.textAlignment = .center
        lb.textColor = .blue
        lb.font = UIFont.systemFont(ofSize: 12)
        return lb
    }()
    
    private lazy var lbImagesSelected: UILabel = {
        let lb = UILabel()
        lb.text = "1 image selected"
        lb.textAlignment = .center
        lb.textColor = .blue
        lb.font = UIFont.systemFont(ofSize: 12)
        return lb
    }()
    private lazy var lbVideoSelected: UILabel = {
        let lb = UILabel()
        lb.text = "1 video selected"
        lb.textAlignment = .center
        lb.textColor = .blue
        lb.font = UIFont.systemFont(ofSize: 12)
        return lb
    }()
    
    
    private lazy var stvTitle: UIStackView = {
        let stv = UIStackView()
        [lbTotalPhotos, lbImagesSelected, lbVideoSelected].forEach { sub in
            stv.addArrangedSubview(sub)
        }
        stv.distribution = .fillEqually
        stv.alignment = .center
        stv.axis = .vertical
        stv.spacing = 2
        return stv
    }()
    
    private lazy var vTop: UIView = {
        let v = UIView()
        [btnCancel, stvTitle, btnSave].forEach { sub in
            v.addSubview(sub)
        }
        v.backgroundColor = .white
        return v
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
        [vTop, cltvPhotos].forEach { sub in
            self.view.addSubview(sub)
        }
        
        self.vTop.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(50)
        }
        
        self.btnCancel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(5)
            make.width.equalTo(70)
        }
        
        self.btnSave.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.trailing.equalToSuperview().offset(-5)
            make.width.equalTo(70)
        }
        
        self.stvTitle.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalTo(self.btnCancel.snp.trailing)
            make.trailing.equalTo(self.btnSave.snp.leading)
        }
        
        self.cltvPhotos.snp.makeConstraints { make in
            make.top.equalTo(self.vTop.snp.bottom)
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
                    if media.filePath == nil {
                        asset.getThumbnailImage(targetSize: CGSize(width: 250, height: 250)) { image in
                            media.thumbnail = image
                            cell.setUpImage(image: image)
                        }
                        asset.getURLImage { responseURL in
                            media.filePath = responseURL
                            media.duration = 0
                        }
                    } else {
                        cell.setUpImage(image: media.thumbnail)
                    }
                } else if media.type == .video {
                    if media.filePath == nil  {
                        asset.avAsset { [weak cell] avAsset in
                            if let avAsset =  avAsset {
                                let thumbnail = Video.shared.getThumbnailImageLocal(asset: avAsset)
                                let duration = avAsset.duration.seconds
                                media.filePath = avAsset.url
                                media.thumbnail = thumbnail
                                media.duration = duration
                                cell?.setupVideo(image: thumbnail, duration: duration)
                            } else {
                                print("no avasset")
                            }
                        }
                    } else {
                        cell.setupVideo(image: media.thumbnail, duration: media.duration)
                    }
                    
                }
                
                cell.isSelect = media.isSelect
                cell.actionSelect = {[weak self, weak cell]  in
                    guard let self = self, let cell = cell else { return }
                    media.isSelect = !media.isSelect
                    cell.isSelect = media.isSelect
                    guard self.photoViewModel.validate(type: media.type ?? .image, url: media.filePath, isSelect: media.isSelect) else {
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
                self?.lbTotalPhotos.text = "Total: \(value.count)"
            })
            .disposed(by: disposeBag)
        
        self.photoViewModel.mediaSelectObservable
            .map({$0.isEmpty})
            .bind(to: self.btnSave.rx.isHidden)
            .disposed(by: disposeBag)
        
        self.photoViewModel.numImage
            .map({$0 == 0})
            .bind(to: self.lbImagesSelected.rx.isHidden)
            .disposed(by: disposeBag)
        
        self.photoViewModel.numVideo
            .map({$0 == 0})
            .bind(to: self.lbVideoSelected.rx.isHidden)
            .disposed(by: disposeBag)
        
        self.photoViewModel.numImage
            .subscribe(onNext: { [weak self] number in
                self?.lbImagesSelected.text = "Images selected: \(number)"
            })
            .disposed(by: disposeBag)
        
        self.photoViewModel.numVideo
            .subscribe(onNext: { [weak self] number in
                self?.lbVideoSelected.text = "Videos selected: \(number)"
            })
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
