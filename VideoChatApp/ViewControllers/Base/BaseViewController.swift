//
//  BaseViewController.swift
//  VideoChatApp
//
//  Created by Khanh Vu on 12/06/5 Reiwa.
//

import UIKit
import RxSwift
import RxCocoa
import Toast_Swift

struct KeyboardData {
    let isShow: Bool
    let duration: TimeInterval
    let height: CGFloat
}

class BaseViewController: UIViewController {

    let disposeBag = DisposeBag()
    let keyboardTrigger = BehaviorRelay<KeyboardData>(value: KeyboardData(isShow: false, duration: 0, height: 0))

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setUpTap()
        bindViewModel()
        bindEvent()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addKeyboardHandler()
        print("===> go to ", self.nibName)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardHandler()
        dismissKeyboard()
        print("<=== dismiss ", self.nibName)
    }
    func setUpUI() {}
    
    func setUpTap() {}
    
    func bindEvent() {}
    
    func bindViewModel() {}
    
    func trackShowToastError(_ viewModel: BaseViewModel, assignView: UIView? = nil) {
        viewModel.errorMsg.asDriverComplete().drive(onNext: { message in
            Toast.show(message)
        }).disposed(by: disposeBag)
    }
    
    func enableButton(_ buttonTap: UIButton?, _ viewBorder: UIView?, isEnable: Bool) {
        viewBorder?.backgroundColor = isEnable ? Constants.Color.bgrButton : Constants.Color.bgrTextField
        buttonTap?.isEnabled = isEnable
    }
    
    func addFirstResponsder(_ textField: UITextField) {
        textField.becomeFirstResponder()
    }
    
    func addGestureDismissKeyboard() {
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
}

//MARK: keyboard Notification
extension BaseViewController {
    private func addKeyboardHandler() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    private func removeKeyboardHandler() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc
    private func keyboardWillChangeFrame(_ notification: NSNotification) {
        animateWithKeyboard(notification: notification) {
            (keyboardFrame, duration) in
            
            let keyboardHeight = self.view.bounds.height - keyboardFrame.origin.y
            print(keyboardHeight)
            let isShow = keyboardFrame.height > 0 ? true : false
            self.keyboardTrigger.accept(KeyboardData(isShow: isShow, duration: duration, height: keyboardHeight))
        }
    }
    
    private func animateWithKeyboard(
        notification: NSNotification,
        animations: ((_ keyboardFrame: CGRect, _ duration: TimeInterval) -> Void)?
    ) {
        // Extract the duration of the keyboard animation
        let durationKey = UIResponder.keyboardAnimationDurationUserInfoKey
        let duration = notification.userInfo![durationKey] as! Double
        
        // Extract the final frame of the keyboard
        let frameKey = UIResponder.keyboardFrameEndUserInfoKey
        let keyboardFrameValue = notification.userInfo![frameKey] as! NSValue
        // Extract the curve of the iOS keyboard animation
        let curveKey = UIResponder.keyboardAnimationCurveUserInfoKey
        let curveValue = notification.userInfo![curveKey] as! Int
        let curve = UIView.AnimationCurve(rawValue: curveValue)!
        
        // Create a property animator to manage the animation
        let animator = UIViewPropertyAnimator(
            duration: duration,
            curve: curve
        ) {
            // Perform the necessary animation layout updates
            animations?(keyboardFrameValue.cgRectValue, duration)
            
            // Required to trigger NSLayoutConstraint changes
            // to animate
            self.view?.layoutIfNeeded()
        }
        // Start the animation
        animator.startAnimation()
    }
}

//MARK: Navigation
extension BaseViewController {
    func push(_ vc: UIViewController, animation: Bool = true) {
        self.navigationController?.pushViewController(vc, animated: animation)
    }
    func pop(animated: Bool = true) {
        navigationController?.popViewController(animated: animated)
    }
    
    func popToRoot(animated: Bool = true) {
        navigationController?.popToRootViewController(animated: animated)
    }
    
    func pop(to: UIViewController, animated: Bool = true) {
        navigationController?.popToViewController(to, animated: animated)
    }
    
    func setRoot(_ vc: UIViewController) {
        self.navigationController?.viewControllers  = [vc]
    }
}

extension BaseViewController {
    func goToTabbarController() {
        let tabbarVC = TabBarController()
        self.setRoot(tabbarVC)
    }
    
    func goToSetRootIntroVC() {
        let introVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "IntroViewController") as! IntroViewController
        self.setRoot(introVC)
    }
}
