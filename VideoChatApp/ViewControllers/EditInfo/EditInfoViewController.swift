//
//  EditInfoViewController.swift
//  VideoChatApp
//
//  Created by Khanh Vu on 13/06/5 Reiwa.
//

import UIKit
import RxSwift
import RxCocoa
class EditInfoViewController: BaseViewController {

    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var vFirstname: UIView!
    @IBOutlet weak var vLastname: UIView!
    @IBOutlet weak var tfFirstname: UITextField!
    @IBOutlet weak var tfLastname: UITextField!
    @IBOutlet weak var vContinue: UIView!
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var bottomBtnConstraint: NSLayoutConstraint!
    @IBOutlet weak var centerVerticalTfConstrants: NSLayoutConstraint!
    
    let viewModel = EditInfoViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func setUpUI() {
        self.view.backgroundColor = Constants.Color.background
        self.btnBack.backgroundColor = Constants.Color.bgrTextField
        self.btnBack.circleClip()
        self.vContinue.backgroundColor = Constants.Color.bgrButton
        self.vContinue.addConnerRadius(radius: 20)
        self.enableButton(btnContinue, vContinue, isEnable: false)
        self.vFirstname.backgroundColor = Constants.Color.bgrTextField
        self.vFirstname.addConnerRadius(radius: 15)
        self.tfFirstname.attributedPlaceholder = "First name".toAttributedStringWithColor(color: .white.withAlphaComponent(0.4))
        self.vLastname.backgroundColor = Constants.Color.bgrTextField
        self.vLastname.addConnerRadius(radius: 15)
        self.tfLastname.attributedPlaceholder = "Last name".toAttributedStringWithColor(color: .white.withAlphaComponent(0.4))
        self.addGestureDismissKeyboard()
        self.addFirstResponsder(self.tfFirstname)
    }
    
    override func setUpTap() {
        self.btnContinue.defaultTap()
            .subscribe(onNext: { [weak self] _ in
                self?.btnContinue.dimButton()
                self?.handleRegister()
            })
            .disposed(by: disposeBag)
        
        self.btnBack.defaultTap()
            .subscribe(onNext: { [weak self] _ in
                self?.btnBack.dimButton()
                self?.pop()
            })
            .disposed(by: disposeBag)
    }
    
    override func bindEvent() {
        self.keyboardTrigger.skip(1).asDriverComplete()
            .drive(onNext: { [weak self] keyboard in
                guard let self = self else { return }
                self.bottomBtnConstraint.constant = keyboard.height + self.viewModel.bottomConstant
                self.centerVerticalTfConstrants.constant = -keyboard.height/2
                UIView.animate(withDuration: keyboard.duration) {
                    self.view.layoutIfNeeded()
                }
            }).disposed(by: disposeBag)
        
        Observable.combineLatest(self.tfFirstname.rx.text, self.tfLastname.rx.text)
                    .map { text1, text2 in
                        return !(text1?.isEmpty ?? true) || !(text2?.isEmpty ?? true)
                    }
                    .subscribe(onNext: { [weak self] isEnable in
                        guard let self = self else {
                            return
                        }
                        self.enableButton(self.btnContinue, self.vContinue, isEnable: isEnable)
                    })
                    .disposed(by: disposeBag)
    }
    
    override func bindViewModel() {
        self.trackShowToastError(viewModel)
        self.tfFirstname.rx.text.orEmpty.bind(to: self.viewModel.firstName).disposed(by: disposeBag)
        self.tfLastname.rx.text.orEmpty.bind(to: self.viewModel.lastName).disposed(by: disposeBag)
    }
    
    func handleRegister() {
        self.viewModel.registerUser()
            .drive(onNext: { [weak self] isSuccess in
                print("go home")
                self?.goToTabbarController()
            })
            .disposed(by: disposeBag)
    }
}

extension EditInfoViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case tfFirstname:
            textField.resignFirstResponder()
            self.tfLastname.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return true
    }
}
