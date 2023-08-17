//
//  PopOverViewController.swift
//  VideoChatApp
//
//  Created by Khanh Vu on 11/08/5 Reiwa.
//

import UIKit

class PopOverViewController: UIViewController {

    @IBOutlet var btnSpeed: [UIButton]!
    var actionTappedSpeed: ((Float) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Do any additional setup after loading the view.
    }
    
    func setupUI() {
        for btn in btnSpeed {
            btn.addTarget(self, action: #selector(btnSpeedTapped(_ :)), for: .touchUpInside)
        }
    }
    
    @objc func btnSpeedTapped(_ sender: UIButton) {
        guard let index = btnSpeed.indexOf(object: sender), let actionTappedSpeed = actionTappedSpeed else{
            return
        }
        let value = Float(index + 1) * 0.25
        print("value: ", value)
        actionTappedSpeed(value)
        self.dismiss(animated: true)
    }
}
