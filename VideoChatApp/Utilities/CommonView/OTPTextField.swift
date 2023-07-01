//
//  OTPTextField.swift
//  VideoChatApp
//
//  Created by Khanh Vu on 13/06/5 Reiwa.
//

import Foundation
import UIKit
protocol OTPTextFieldDelegate: NSObject{
    func textFieldDidDelete(_ textField: OTPTextField,_ isEndCode: Bool)
}

class NoActionTextField: UITextField {
    var enableLongPressActions = false

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return enableLongPressActions
    }
}
class OTPTextField: NoActionTextField {
    weak var previousTextField: NoActionTextField?
    weak var nextTextFiled: NoActionTextField?
    weak var myCustomTextFieldDelegate : OTPTextFieldDelegate?
    var check = false
    
    override func deleteBackward() {
        super.deleteBackward()
        
        print("detete: \(String(describing: text))")
        if check {
            myCustomTextFieldDelegate?.textFieldDidDelete(self, check)
            check = false
        }else {
            myCustomTextFieldDelegate?.textFieldDidDelete(self, check)
            previousTextField?.becomeFirstResponder()
        }
        
    }
}

