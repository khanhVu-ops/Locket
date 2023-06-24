//
//  ImageScrollView.swift
//  VideoChatApp
//
//  Created by Khanh Vu on 11/05/5 Reiwa.
//

import UIKit

class ImageScrollView: UIScrollView, UIScrollViewDelegate {

    var imageZoomView =  UIImageView()
    var cellSize: CGSize!
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.delegate = self
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
        self.decelerationRate = UIScrollView.DecelerationRate.fast
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setCenterImage()
    }
    
    func set(image: UIImage) {
        imageZoomView.removeFromSuperview()
        imageZoomView = UIImageView(image: image)
        imageZoomView.addConnerRadius(radius: 20)
        self.addSubview(imageZoomView)
        self.configurateFor(imageSize: image.size)
    }
    
    func configurateFor(imageSize: CGSize) {
        self.contentSize = imageSize
        self.setCurrentMaxAndMinZoomScale()
        self.zoomScale = self.minimumZoomScale
    }
    
    func setCurrentMaxAndMinZoomScale() {
        let boundsSize = self.cellSize ?? .zero
        let imageSize = self.imageZoomView.bounds.size
        let xScale = boundsSize.width / imageSize.width
        let yScale = boundsSize.height / imageSize.height
        let minScale = min(xScale, yScale)
        var maxScale = 1.0
        if minScale < 0.1 {
            maxScale = 0.3
        }
        if minScale > 0.1 , minScale < 0.5 {
            maxScale = 0.7
        }
        if minScale > 0.5 {
            maxScale = max(1.0, minScale)
        }

        self.minimumZoomScale = minScale
        self.maximumZoomScale = maxScale
    }
    
    func setCenterImage() {
        let boundsSize = self.bounds.size
        var frameToCenter = imageZoomView.frame
        if frameToCenter.size.width < boundsSize.width {
            frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width)/2
        } else {
            frameToCenter.origin.x = 0
        }
        if frameToCenter.size.height < boundsSize.height {
            frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height)/2
        } else {
            frameToCenter.origin.y = 0
        }
        imageZoomView.frame = frameToCenter
    }
    // Delegate
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageZoomView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.setCenterImage()
    }
}
