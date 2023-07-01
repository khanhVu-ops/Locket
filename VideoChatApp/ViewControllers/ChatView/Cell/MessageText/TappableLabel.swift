//
//  TappedLabel.swift
//  VideoChatApp
//
//  Created by Khanh Vu on 27/06/5 Reiwa.
//

import Foundation
import UIKit
class TappableLabel: UILabel {
    var linkTapHandler: ((URL?) -> Void)?
    var phoneTapHandler: ((String?) -> Void)?
    var textTapHanlder: (() -> Void)?
    var edgeInset: UIEdgeInsets = .zero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets.init(top: edgeInset.top, left: edgeInset.left, bottom: edgeInset.bottom, right: edgeInset.right)
        super.drawText(in: rect.inset(by: insets))
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + edgeInset.left + edgeInset.right, height: size.height + edgeInset.top + edgeInset.bottom)
    }
    
    private func setup() {
        isUserInteractionEnabled = true
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(labelTapped(_:))))
    }
    
    @objc private func labelTapped(_ gesture: UITapGestureRecognizer) {
        guard let label = gesture.view as? UILabel, let attributedText = label.attributedText else {
            return
        }
        
        let location = gesture.location(in: label)
        let textContainer = NSTextContainer(size: label.bounds.size)
        let layoutManager = NSLayoutManager()
        let textStorage = NSTextStorage(attributedString: attributedText)
        
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        let characterIndex = layoutManager.characterIndex(for: location, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue |
                                           NSTextCheckingResult.CheckingType.link.rawValue)
        detector.enumerateMatches(in: attributedText.string, options: [], range: NSRange(location: 0, length: attributedText.length)) { (result, _, stop) in
            
            if let result = result {
                switch result.resultType {
                case .phoneNumber:
                    if let phoneNumber = result.phoneNumber {
                        let glyphRange = layoutManager.glyphRange(forCharacterRange: result.range, actualCharacterRange: nil)
                        if NSLocationInRange(characterIndex, glyphRange) {
                            phoneTapHandler?(phoneNumber)
                            stop.pointee = true
                        } else {
                            textTapHanlder?()
                        }
                    } else {
                        textTapHanlder?()
                    }
                case .link:
                    if let url = result.url {
                        let glyphRange = layoutManager.glyphRange(forCharacterRange: result.range, actualCharacterRange: nil)
                        if NSLocationInRange(characterIndex, glyphRange) {
                            linkTapHandler?(url)
                            stop.pointee = true
                        } else {
                            textTapHanlder?()
                        }
                    } else {
                        textTapHanlder?()
                    }
                default:
                    textTapHanlder?()
                }
                
            } else {
                textTapHanlder?()
            }
            return
        }
        textTapHanlder?()
        return
    }
}
