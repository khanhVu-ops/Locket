//
//  DetailImageCollectionViewCell.swift
//  VideoChatApp
//
//  Created by Khanh Vu on 31/03/5 Reiwa.
//

import UIKit
import AVFoundation
import SnapKit
import AVKit
class DetailImageCollectionViewCell: UICollectionViewCell, UIScrollViewDelegate {
    private lazy var imvDetail: UIImageView = {
        let imv = UIImageView()
        imv.contentMode = .scaleAspectFit
        imv.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(scaleImage(_:))))
        imv.isUserInteractionEnabled = true
        return imv
    }()
    var scrollView: UIScrollView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        scrollView = UIScrollView(frame: self.bounds)
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(scrollView)
        scrollView.addSubview(imvDetail)
//        self.addSubview(self.imvDetail)
        self.imvDetail.addConnerRadius(radius: 20)
        scrollView.contentSize = self.imvDetail.bounds.size
        scrollView.maximumZoomScale = 4.0 // giá trị tối đa cho phép phóng to hình ảnh
        scrollView.minimumZoomScale = 1.0 // giá trị tối thiểu cho phép thu nhỏ hình ảnh
        scrollView.delegate = self // đăng ký đối tượng delegate để xử lý sự kiện phóng to/thu nhỏ
        // Initialization code
    }
    override func prepareForReuse() {
        print("Reuse detail image")
    }
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imvDetail
    }

    func loadImage(url: String) {
        if let imageUrl = URL(string: url) {
            self.imvDetail.sd_setImage(with: imageUrl, completed: { (image, error, cacheType, url) in
                if let image = image {
                    // Lấy kích thước của hình ảnh và tính tỷ lệ
                    let ratio = image.size.height / image.size.width
                    print("Tỷ lệ của hình ảnh là: \(ratio)")
                    
                    DispatchQueue.main.async {
                        self.imvDetail.snp.removeConstraints()
                        if (self.frame.width - 20) * ratio > self.frame.height  {
                            self.imvDetail.snp.makeConstraints { make in
                                make.centerX.centerY.equalToSuperview()
                                make.height.equalToSuperview().offset(-10)
                                make.width.equalTo(self.imvDetail.snp.height).multipliedBy(1/ratio)
                            }
                        } else {
                            self.imvDetail.snp.makeConstraints { make in
                                make.centerX.centerY.equalToSuperview()
                                make.width.equalToSuperview().offset(-20)
                                make.height.equalTo(self.imvDetail.snp.width).multipliedBy(ratio)
                            }
                        }
                        
                        self.imvDetail.frame.size.height = (self.frame.width - 20) * ratio
                        self.layoutIfNeeded()
                    }
                }
            })
        } else {
            self.imvDetail.image = UIImage(named: "library")
            print("Invalid URL")
        }
    }
    
    @objc func scaleImage(_ recognizer: UIPinchGestureRecognizer) {
        guard recognizer.view != nil else { return }
        let scale = recognizer.scale
        let location = recognizer.location(in: recognizer.view)
        if recognizer.state == .began {
            let x = location.x - self.imvDetail.bounds.midX
            let y = location.y - self.imvDetail.bounds.midY
            // set lại kích thước và vị trí của ảnh
//                self.imvDetail.frame = CGRect(x: newX, y: newY, width: newWidth, height: newHeight)
            self.imvDetail.transform = CGAffineTransform(translationX: -x, y: -y)
        } else if recognizer.state == .changed {
                
                
                // tính toán kích thước mới của ảnh dựa trên scale và vị trí của tay người dùng
                let newWidth = self.imvDetail.frame.width * scale
                let newHeight = self.imvDetail.frame.height * scale
            self.imvDetail.transform = CGAffineTransform(scaleX: scale, y: scale)

                // reset scale về 1 để tính toán tiếp theo lần pinch
//                recognizer.scale = 1.0
            }
    }

















































}
