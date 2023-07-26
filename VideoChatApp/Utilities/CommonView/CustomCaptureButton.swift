//
//  CustomCaptureButton.swift
//  IntergrateMLModel
//
//  Created by Khanh Vu on 29/03/5 Reiwa.
//

import UIKit
import SnapKit
class CustomCaptureButton: UIView {

    private lazy var vCenter: UIView = {
        let v = UIView()
        v.backgroundColor = .clear
        return v
    }()
    
    private lazy var btnEnter: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .clear
        btn.tintColor = .black
        btn.addTarget(self, action: #selector(didEnter(_:)), for: .touchUpInside)
        btn.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPressEnter(_:))))
        return btn
    }()
    
    var actionTapEnter: (()->Void)?
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpView(frame: frame)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpView(frame: CGRect) {
        [vCenter, btnEnter].forEach { sub in
            self.addSubview(sub)
        }
        
        vCenter.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview().inset(8)
        }
        
        btnEnter.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalToSuperview().inset(0)
        }
        
        self.addBorder(borderWidth: 4, borderColor: .white)
        self.backgroundColor = .black
        vCenter.backgroundColor = .white
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.addConnerRadius(radius: frame.width/2)
        btnEnter.addConnerRadius(radius: btnEnter.frame.width/2)
        vCenter.addConnerRadius(radius: vCenter.frame.width/2)
        
    }
    
    func animateTapped() {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) { [weak self] in
            self?.vCenter.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        } completion: { [weak self] _ in
            self?.vCenter.transform = CGAffineTransform(scaleX: 1, y: 1)
            if let actionTapEnter = self?.actionTapEnter {
                actionTapEnter()
            }
        }
    }
    
    @objc func didEnter(_ sender: UIButton) {
        sender.dimButton()
        animateTapped()
        
    }
    
    @objc func longPressEnter(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            self.vCenter.animateScale(scale: 0.6)
        } else if gesture.state == .ended {
            self.vCenter.animateScale(scale: 1.0)
            if let actionTapEnter = actionTapEnter {
                self.btnEnter.dimButton()
                actionTapEnter()
            }
        }
    }
    
    func showCheckMark(isShow: Bool) {
        isShow ? btnEnter.setImage(Constants.Image.checkMarkSystem.resize(with: CGSize(width: 30, height: 30)), for: .normal) : btnEnter.setImage(nil, for: .normal)
        btnEnter.backgroundColor = isShow ? .white : .clear
    }
}
