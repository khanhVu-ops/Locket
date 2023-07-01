//
//  RegisterViewController.swift
//  VideoChatApp
//
//  Created by Khanh Vu on 12/06/5 Reiwa.
//

import UIKit
import RxSwift
import RxCocoa
class RegisterViewController: BaseViewController {

    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var vContinue: UIView!
    @IBOutlet weak var tfPhoneNumber: NoActionTextField!
    @IBOutlet weak var vPhoneNumber: UIView!
    @IBOutlet weak var bottomBtnConstraint: NSLayoutConstraint!
    @IBOutlet weak var centerVerticalTfConstrants: NSLayoutConstraint!
    let viewModel = RegisterViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.addFirstResponsder(self.tfPhoneNumber)
    }
    
    override func setUpUI() {
        self.view.backgroundColor = Constants.Color.background
        self.btnBack.backgroundColor = Constants.Color.bgrTextField
        self.btnBack.circleClip()
        self.vContinue.backgroundColor = Constants.Color.bgrButton
        self.vContinue.addConnerRadius(radius: 20)
        self.enableButton(btnContinue, vContinue, isEnable: false)
        self.vPhoneNumber.backgroundColor = Constants.Color.bgrTextField
        self.vPhoneNumber.addConnerRadius(radius: 15)
        self.tfPhoneNumber.attributedPlaceholder = "123456789".addSpaceToPhoneNumber().toAttributedStringWithColor(color: .gray.withAlphaComponent(0.2))
        self.addGestureDismissKeyboard()
    }
    
    override func setUpTap() {
        btnBack.defaultTap()
            .bind{ [weak self] in
                self?.btnBack.dimButton()
                self?.pop()
            }
            .disposed(by: disposeBag)
        
        btnContinue.defaultTap()
            .bind { [weak self] _ in
                guard let self = self else {
                    return
                }
                self.btnContinue.dimButton()
                self.goToValidateCodeVC()
            }.disposed(by: disposeBag)
            
    }
    
    override func bindEvent() {
        self.trackShowToastError(viewModel)
        self.keyboardTrigger.skip(1).asDriverComplete()
            .drive(onNext: { [weak self] keyboard in
                guard let self = self else { return }
                self.bottomBtnConstraint.constant = keyboard.height + self.viewModel.bottomConstant
                self.centerVerticalTfConstrants.constant = -keyboard.height/2
                UIView.animate(withDuration: keyboard.duration) {
                    self.view.layoutIfNeeded()
                }
            }).disposed(by: disposeBag)
        
        self.tfPhoneNumber.rx.controlEvent(.editingChanged)
            .withLatestFrom(self.tfPhoneNumber.rx.text.orEmpty)
            .subscribe(onNext: { [weak self] text in
                text.isValidPhoneNumber() ? self?.enableButton(self?.btnContinue, self?.vContinue, isEnable: true) : self?.enableButton(self?.btnContinue, self?.vContinue, isEnable: false)
            }).disposed(by: disposeBag)
        
        self.tfPhoneNumber.rx.controlEvent(.editingDidEnd)
            .withLatestFrom(self.tfPhoneNumber.rx.text.orEmpty)
            .subscribe(onNext: { [weak self] text in
                print(text)
                self?.tfPhoneNumber.text = text.addSpaceToPhoneNumber()
            })
            .disposed(by: disposeBag)
        
        self.tfPhoneNumber.rx.controlEvent((.editingDidBegin))
            .withLatestFrom(self.tfPhoneNumber.rx.text.orEmpty)
            .subscribe(onNext: { [weak self] text in
                self?.tfPhoneNumber.text = text.removeAllSpace()
            })
            .disposed(by: disposeBag)
    }
    
    func goToValidateCodeVC() {
//        let loginVC  = VerifyCodeViewController()
//        self.push(loginVC)
//        UserDefaultManager.shared.setID(id: "b9oCvYOP5PQhqHZiGtC4ua4uHBG2")
        self.viewModel.sendPhoneCode(with: self.tfPhoneNumber.text ?? "")
            .drive(onNext: { [weak self] code in
                print("codeeee:", code)
                let verifyVC  = VerifyCodeViewController()
                verifyVC.viewModel.verificationID = code
                verifyVC.viewModel.phoneNumber = self?.tfPhoneNumber.text ?? ""
                self?.push(verifyVC)
            })
            .disposed(by: self.disposeBag)
       
    }
}
