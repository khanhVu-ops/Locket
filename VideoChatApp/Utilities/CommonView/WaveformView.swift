//
//  WaveformView.swift
//  VideoChatApp
//
//  Created by Khanh Vu on 17/04/5 Reiwa.
//

import Foundation
import UIKit

class WaveformView: UIView {
    var waveformPoints = [CGPoint]()
    var waveformColor = UIColor.white
    var firstPoint = CGPoint(x: 0, y: 20)
    override func draw(_ rect: CGRect) {
        firstPoint = CGPoint(x: 0, y: self.frame.midY)
        let path = UIBezierPath()
        waveformColor.setStroke()
        path.lineWidth = 2.0
        for (index, point) in waveformPoints.enumerated() {
            path.move(to: CGPoint(x: point.x, y: firstPoint.y))
            path.addLine(to: CGPoint(x: point.x, y: firstPoint.y + point.y))
            
            path.move(to: CGPoint(x: point.x, y: firstPoint.y))
            path.addLine(to: CGPoint(x: point.x, y: firstPoint.y - point.y))
        }
        path.stroke()
    }
    func update(withWaveformHeight waveformHeight: CGFloat) {
        let point = CGPoint(x: firstPoint.x + CGFloat(waveformPoints.count * 4), y: waveformHeight)
        waveformPoints.append(point)
        setNeedsDisplay()
    }
    
    func clear() {
        waveformPoints.removeAll()
        setNeedsDisplay()
    }
}
