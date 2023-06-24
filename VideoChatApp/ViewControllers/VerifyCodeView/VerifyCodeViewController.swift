//
//  VerifyCodeViewController.swift
//  VideoChatApp
//
//  Created by Khanh Vu on 13/06/5 Reiwa.
//

import UIKit

class VerifyCodeViewController: BaseViewController {

    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var vContinue: UIView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var stvOTP: OTPStackView!
    @IBOutlet weak var lbSentTo: UILabel!
    @IBOutlet weak var lbCountDown: UILabel!
    @IBOutlet weak var btnTryAgain: UIButton!
    @IBOutlet weak var bottomBtnConstraint: NSLayoutConstraint!
    @IBOutlet weak var centerVerticalTfConstrants: NSLayoutConstraint!
    
    private var timer: Timer?
    var originTime = 0.0
    var counter = 0
    let viewModel = VerifyCodeViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.addFirstResponsder(stvOTP.textFieldArray[0])
        if timer == nil {
            self.continueCountDown()
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.stopTimer()
    }
    
    override func setUpUI() {
        self.view.backgroundColor = Constants.Color.background
        self.btnBack.backgroundColor = Constants.Color.bgrTextField
        self.btnBack.circleClip()
        self.vContinue.backgroundColor = Constants.Color.bgrButton
        self.vContinue.addConnerRadius(radius: 20)
        self.enableButton(btnContinue, vContinue, isEnable: false)
        stvOTP.configTextFieldView(backgroundColor: Constants.Color.bgrTextField,
                                   tintColor: .white,
                                   textAlignment: .center,
                                   borderStyle: .none,
                                   font: UIFont.systemFont(ofSize: 20, weight: .medium),
                                   keyboardType: .numberPad,
                                   editingBorderColor: .white.withAlphaComponent(0.5),
                                   nonEditingborderColor: .clear,
                                   borderWidth: 1,
                                   cornerRadius: 10)
        stvOTP.otpValueDidChanged = {[weak self] in
            guard let self = self else { return}
            self.enableButton(self.btnContinue, self.vContinue, isEnable: $0.count == 6)
        }
        self.lbSentTo.textColor = .lightGray
        self.lbSentTo.text = "Sent to \(viewModel.phoneNumber)"
        self.lbCountDown.textColor = .lightGray
        self.btnTryAgain.setAttributedTitle("Try again!".toAttributedStringWithUnderlineAndColor(color: .blue), for: .normal)
        self.addGestureDismissKeyboard()
    }
    
    override func setUpTap() {
        self.btnBack.defaultTap()
            .subscribe(onNext: { [weak self] _ in
                self?.btnBack.dimButton()
                self?.pop()
            })
            .disposed(by: disposeBag)
        
        self.btnTryAgain.defaultTap()
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else {
                    return
                }
                self.btnTryAgain.dimButton()
                self.viewModel.sendCodeAgain()
                    .drive(onNext: { [weak self] code in
                        print("again", code)
                        self?.viewModel.verificationID = code
                        self?.viewModel.countDounBehavior.accept(60)
                    })
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
        
        self.btnContinue.defaultTap()
            .subscribe(onNext: { [weak self] _ in
                self?.btnContinue.dimButton()
                self?.handleVerifyCode()
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
    }
    
    override func bindViewModel() {
        self.trackShowToastError(viewModel)
        self.viewModel.countDounBehavior
            .subscribe(onNext: { [weak self] duration in
                self?.startCountDown(duration: duration)
            })
            .disposed(by: disposeBag)
    }
    
    private func handleVerifyCode() {
        if counter == 0 {
            self.viewModel.errorMsg.accept("Code is expried, Please Try again!")
        } else {
            self.viewModel.verifyPhoneCode(self.stvOTP.getOTPString())
                .drive(onNext: { [weak self] uid in
                    guard let self = self else {
                        return
                    }
                    print("UID:", uid)
                    self.viewModel.countDounBehavior.accept(0)
                    self.viewModel.checkAccountExits(uid)
                        .subscribe { [weak self] single in
                            switch single {
                            case .success(let user):
                                UserDefaultManager.shared.setID(id: user.id)
                                self?.goToTabbarController()
                            case .failure(_):
                                let editInfoVC = EditInfoViewController()
                                editInfoVC.viewModel.phoneNumber = self?.viewModel.phoneNumber ?? ""
                                editInfoVC.viewModel.uid = uid
                                self?.push(editInfoVC)
                            }
                        }
                        .disposed(by: self.disposeBag)
                })
                .disposed(by: disposeBag)
        }
    }
    
    func startCountDown(duration: Int) {
        stopTimer()
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
        originTime = Date().timeIntervalSince1970 + TimeInterval(duration)
        counter = duration
        self.updateUIWhenCountDown(isFinish: false)
        
    }
    
    func continueCountDown() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
        self.updateUIWhenCountDown(isFinish: false)
    }
    
    @objc func updateCounter() {
        counter = max(0, Int(originTime - Date().timeIntervalSince1970))
        self.lbCountDown.text = "Try again in \(counter) seconds"
        if counter == 0 {
            stopTimer()
            self.updateUIWhenCountDown(isFinish: true)
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func updateUIWhenCountDown(isFinish: Bool) {
        self.lbCountDown.isHidden = isFinish
        self.btnTryAgain.isHidden = !isFinish
    }
}
