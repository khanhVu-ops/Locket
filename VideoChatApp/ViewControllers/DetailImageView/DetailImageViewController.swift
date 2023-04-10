//
//  DetailImageViewController.swift
//  FlowerClassification
//
//  Created by Khanh Vu on 30/03/5 Reiwa.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Photos
class DetailImageViewController: UIViewController {
    
    private lazy var btnCancel: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "xmark"), for: .normal)
        btn.tintColor = .black
        btn.addTarget(self, action: #selector(btnCancelTapped), for: .touchUpInside)
        return btn
    }()
    
    private lazy var btnDownload: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "arrow.down.to.line.compact"), for: .normal)
        btn.tintColor = .black
        btn.addTarget(self, action: #selector(btnDownloadTapped), for: .touchUpInside)
        return btn
    }()
    
    private lazy var lbCountItem: UILabel = {
        let lb = UILabel()
        lb.text = "1/10"
        lb.textColor = .black
        lb.font = UIFont.systemFont(ofSize: 17)
        lb.textAlignment = .center
        return lb
    }()
    
    private lazy var lbTypeFile: UILabel = {
        let lb = UILabel()
        lb.text = "image"
        lb.textColor = .black
        lb.font = UIFont.systemFont(ofSize: 17)
        lb.textAlignment = .center
        return lb
    }()
    
    private lazy var stvLabelItem: UIStackView = {
        let stv = UIStackView()
        [lbCountItem, lbTypeFile].forEach { sub in
            stv.addArrangedSubview(sub)
        }
        stv.distribution = .fillEqually
        stv.alignment = .center
        stv.axis = .vertical
        return stv
    }()
    
    private lazy var stvTop: UIStackView = {
        let stv = UIStackView()
        [btnCancel, stvLabelItem, btnDownload].forEach { sub in
            stv.addArrangedSubview(sub)
        }
        stv.distribution = .fill
        stv.alignment = .center
        stv.axis = .horizontal
        return stv
    }()
    
    private lazy var cltvListImage: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let cltv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cltv.showsHorizontalScrollIndicator = false
        cltv.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        cltv.layer.masksToBounds = true
        cltv.isPagingEnabled = true
        
        return cltv
    }()
    
    private lazy var myPageControl: UIPageControl = {
        let page = UIPageControl()
        page.currentPage = 0
        page.pageIndicatorTintColor = .gray.withAlphaComponent(0.4)
        page.currentPageIndicatorTintColor = .black.withAlphaComponent(0.7)
        return page
    }()
    
    private lazy var btnNext: UIButton = {
        let btn = UIButton()
        btn.setBackgroundImage(UIImage(systemName: "chevron.right"), for: .normal)
        btn.tintColor = .gray.withAlphaComponent(0.4)
        btn.addTarget(self, action: #selector(btnNextTapped), for: .touchUpInside)
        return btn
    }()
    
    private lazy var btnPrevious: UIButton = {
        let btn = UIButton()
        btn.setBackgroundImage(UIImage(systemName: "chevron.left"), for: .normal)
        btn.tintColor = .gray.withAlphaComponent(0.4)
        btn.addTarget(self, action: #selector(btnPreviousTapped), for: .touchUpInside)
        return btn
    }()
    
    private lazy var btnLibary: UIButton = {
        let btn = UIButton()
        btn.setBackgroundImage(UIImage(systemName: "photo"), for: .normal)
        btn.tintColor = .black
        btn.addTarget(self, action: #selector(btnLibraryTapped), for: .touchUpInside)
        return btn
    }()
    
    
    let detailImageViewModel = DetailImageViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureView()
        self.bindDataToViewModel()
        // Do any additional setup after loading the view.
    }
    
    func configureView() {
        [stvTop, cltvListImage, myPageControl, btnPrevious, btnNext, btnLibary].forEach { subView in
            self.view.addSubview(subView)
        }
        self.view.backgroundColor = .white
        
        self.stvTop.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
        
        self.btnCancel.snp.makeConstraints { make in
            make.width.height.equalTo(40)
        }
        self.btnDownload.snp.makeConstraints { make in
            make.width.height.equalTo(40)
        }
        
        self.myPageControl.snp.makeConstraints { make in
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-10)
            make.centerX.equalToSuperview()
            make.width.equalTo(150)
            
        }
        self.myPageControl.numberOfPages = self.detailImageViewModel.listImages.value.count
        
        self.cltvListImage.snp.makeConstraints { make in
            make.top.equalTo(self.stvTop.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(self.myPageControl.snp.top).offset(-20)
        }
        
        self.btnNext.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.width.equalTo(30)
            make.trailing.equalToSuperview().offset(-10)
            make.centerY.equalTo(self.cltvListImage.snp.centerY)
        }
        
        self.btnPrevious.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.width.equalTo(30)
            make.leading.equalToSuperview().offset(10)
            make.centerY.equalTo(self.cltvListImage.snp.centerY)
        }
        
        self.btnLibary.snp.makeConstraints { make in
            make.width.equalTo(40)
            make.height.equalTo(30)
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalTo(self.myPageControl.snp.centerY)
        }
        
    }
    
    func bindDataToViewModel() {
        self.cltvListImage.register(UINib(nibName: "DetailImageCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "DetailImageCollectionViewCell")
        self.cltvListImage.register(UINib(nibName: "DetailVideoCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "DetailVideoCollectionViewCell")
        
        self.detailImageViewModel.listImages
            .bind(to: self.cltvListImage.rx.items) { collectionView, index, element -> UICollectionViewCell in
                switch element.type {
                case .image:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DetailImageCollectionViewCell", for: IndexPath(row: index, section: 0)) as! DetailImageCollectionViewCell
                    cell.loadImage(url: element.url)
                    return cell
                case.video:
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DetailVideoCollectionViewCell", for: IndexPath(row: index, section: 0)) as! DetailVideoCollectionViewCell
                    cell.configure(item: element)
                    return cell
                }
            }
            .disposed(by: disposeBag)
        self.cltvListImage.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        self.detailImageViewModel.listImages
            .subscribe(onNext: { [weak self] _ in
                DispatchQueue.main.async {
                    self?.detailImageViewModel.scrollToCurrentURL(collectionView: self?.cltvListImage)
                }
            })
            .disposed(by: disposeBag)
        
        self.detailImageViewModel.indexItemBehavior
            .subscribe(onNext: { [weak self] index in
                let count = self?.detailImageViewModel.listImages.value.count ?? 1
                self?.lbCountItem.text = "\(index + 1)/\(count)"
                self?.lbTypeFile.text = self?.detailImageViewModel.listImages.value[index].type == .image ? "Image" : "Video"
                self?.btnNext.isHidden = false
                self?.btnPrevious.isHidden = false
                if index == 0 {
                    self?.btnPrevious.isHidden = true
                }
                if index == (self?.detailImageViewModel.listImages.value.count ?? 1) - 1 {
                    self?.btnNext.isHidden = true
                }
            })
            .disposed(by: disposeBag)
    }
    
    @objc func btnNextTapped() {
        let visibleIndexPaths = cltvListImage.indexPathsForVisibleItems
        if let lastIndexPath = visibleIndexPaths.last {
            let nextIndexPath = IndexPath(item: lastIndexPath.item + 1, section: lastIndexPath.section)
            cltvListImage.scrollToItem(at: nextIndexPath, at: .left, animated: true)
            self.detailImageViewModel.indexItemBehavior.accept(lastIndexPath.item + 1)
        }
    }
    
    @objc func btnPreviousTapped() {
        let visibleIndexPaths = cltvListImage.indexPathsForVisibleItems
        if let lastIndexPath = visibleIndexPaths.last {
            let nextIndexPath = IndexPath(item: lastIndexPath.item - 1, section: lastIndexPath.section)
            cltvListImage.scrollToItem(at: nextIndexPath, at: .left, animated: true)
            self.detailImageViewModel.indexItemBehavior.accept(lastIndexPath.item - 1)
        }
    }
    
    @objc func btnCancelTapped() {
        self.dismiss(animated: true, completion: nil)
//        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func btnDownloadTapped() {
        
    }
    
    @objc func btnLibraryTapped() {
        let photosVC = PhotosViewController()
        photosVC.delegate = self
        self.present(photosVC, animated: true, completion: nil)
//        self.navigationController?.pushViewController(photosVC, animated: true)
    }
    
}

extension DetailImageViewController: PhotosDelegate {
    func didTapSendImage(assets: [AssetModel]) {
        for asset in assets {
            if asset.type == .image {
                // handle image
                let manager = PHImageManager.default()
                let requestOptions = PHImageRequestOptions()
                requestOptions.isNetworkAccessAllowed = true
                
                // Fetch the image data
                manager.requestImageDataAndOrientation(for: asset.asset, options: requestOptions) { imageData, _, _, _ in
                    if let imageData = imageData {
                        // Generate a unique file name for the image
                        let uniqueFileName = ProcessInfo.processInfo.globallyUniqueString
                        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(uniqueFileName).jpg")
                        
                        do {
                            // Save the image data to the file URL
                            try imageData.write(to: fileURL)
                            var newArr = self.detailImageViewModel.listImages.value
                            newArr.append(DetailItem(type: .image, url: "\(fileURL)"))
                            self.detailImageViewModel.listImages.accept(newArr)
                            
                        } catch {
                            print("Error saving image to URL: \(error.localizedDescription)")
                        }
                    } else {
                        print("Can't get url")
                    }
                }

            } else if asset.type == .video {
                // handle video
                let manager = PHImageManager.default()
                let requestOptions = PHVideoRequestOptions()
                requestOptions.isNetworkAccessAllowed = true
                
                // Fetch the URL of the video
                manager.requestAVAsset(forVideo: asset.asset, options: requestOptions, resultHandler: { (avAsset, audioMix, info) in
                    if let avURLAsset = avAsset as? AVURLAsset {
                        let videoURL = avURLAsset.url
                        var newArr = self.detailImageViewModel.listImages.value
                        newArr.append(DetailItem(type: .video, url: "\(videoURL)"))
                        self.detailImageViewModel.listImages.accept(newArr)
                        // Use the videoURL as needed
                    }
                })
            }
        }
    }
}

extension DetailImageViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.cltvListImage.frame.width, height: self.cltvListImage.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let myCell = cell as? DetailVideoCollectionViewCell {
            if self.detailImageViewModel.listImages.value[indexPath.row].isPlaying {
                myCell.playVideo()
            }
        }
        myPageControl.currentPage = indexPath.row
        self.detailImageViewModel.indexItemBehavior.accept(indexPath.row)
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let myCell = cell as? DetailVideoCollectionViewCell {
            myCell.player.pause()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        var currentPage = Int(scrollView.contentOffset.x/UIScreen.main.bounds.width)
        
        currentPage = min(currentPage, self.detailImageViewModel.listImages.value.count - 1)
        currentPage = max(currentPage, 0)
        myPageControl.currentPage = currentPage
        self.detailImageViewModel.indexItemBehavior.accept(currentPage)
    }
    
}
