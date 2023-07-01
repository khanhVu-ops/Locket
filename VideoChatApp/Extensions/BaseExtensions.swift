//
//  BaseExtensions.swift
//  VideoChatApp
//
//  Created by Khanh Vu on 28/06/5 Reiwa.
//

import Foundation
import UIKit

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension URL {
    func fileSize() -> Double {
        var fileSize: Double = 0.0
        var fileSizeValue = 0.0
        try? fileSizeValue = (self.resourceValues(forKeys: [URLResourceKey.fileSizeKey]).allValues.first?.value as! Double?)!
        if fileSizeValue > 0.0 {
            fileSize = (Double(fileSizeValue) / (1024 * 1024))
        }
        return fileSize
    }
}

public extension UIScrollView {
    func scrollToBottom(animated: Bool = false) {
        let bottomRect = CGRect(x: contentSize.width - 1, y: contentSize.height - 1, width: 1, height: 1)
        self.scrollRectToVisible(bottomRect, animated: animated)
    }
    
    func scrollToTop(animated: Bool) {
        setContentOffset(.zero, animated: animated)
    }
}

public extension Array where Element: Equatable {
    // Remove first collection element that is equal to the given `object`:
    mutating func remove(object: Element) {
        if let index = firstIndex(of: object) {
            remove(at: index)
        }
    }
    // Append a element that is not in array:
    mutating func appendUnduplicate(object: Element) {
        if !contains(object) {
            append(object)
        }
    }
    
    func indexOf(object: Element) -> Int? {
        return (self as NSArray).contains(object) ? (self as NSArray).index(of: object) : nil
    }
    
    subscript(index index: Int) -> Element? {
        guard index >= 0, index < endIndex else {
            return nil
        }
        
        return self[index]
    }
}

public extension Array where Element: Comparable {
    func containsElements(as other: [Element]) -> Bool {
        for element in other {
            if !self.contains(element) { return false }
        }
        return true
    }
}

extension UIApplication {
    static var applicationVersion: String {
        return (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String) ?? "1.0.0"
    }
    
    static var applicationBuild: String {
        return (Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String) ?? "1"
    }
    
    static var appVersionBuild: String {
        let version = self.applicationVersion
        let build = self.applicationBuild
        
        return "v\(version)(\(build))"
    }
    
    class func openUrlString(_ urlString: String?) {
        if let stringUrl = urlString, let url = URL(string: stringUrl) {
            if #available(iOS 10.0, *) {
                self.shared.open(url, options: [:], completionHandler: nil)
            } else {
                self.shared.openURL(url)
            }
        }
    }
    
    var statusBarUIView: UIView? {
        
        if #available(iOS 13.0, *) {
            let tag = 3848245
            
            let keyWindow = UIApplication.shared.connectedScenes
                .map({$0 as? UIWindowScene})
                .compactMap({$0})
                .first?.windows.first
            
            if let statusBar = keyWindow?.viewWithTag(tag) {
                return statusBar
            } else {
                let height = keyWindow?.windowScene?.statusBarManager?.statusBarFrame ?? .zero
                let statusBarView = UIView(frame: height)
                statusBarView.tag = tag
                statusBarView.layer.zPosition = 999999
                
                keyWindow?.addSubview(statusBarView)
                return statusBarView
            }
            
        } else {
            
            if responds(to: Selector(("statusBar"))) {
                return value(forKey: "statusBar") as? UIView
            }
        }
        return nil
    }
    
    static var statusBarView: UIView? {
        return UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
    }
    
    static func switchRootViewController(to rootViewController: UIViewController, animated: Bool = true, completion: ((Bool) -> Void)? = nil) {
        guard let window = UIApplication.shared.keyWindow ?? UIApplication.shared.windows.first else {
            completion?(false)
            return
        }
        
        if animated {
            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
                let oldState: Bool = UIView.areAnimationsEnabled
                UIView.setAnimationsEnabled(false)
                window.rootViewController = rootViewController
                UIView.setAnimationsEnabled(oldState)
            }, completion: { (finished: Bool) -> () in
                completion?(true)
            })
        } else {
            window.rootViewController = rootViewController
            completion?(true)
        }
    }
}
