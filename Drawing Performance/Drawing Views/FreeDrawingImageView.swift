//
//  FreeDrawingImageView.swift
//
//  Created by Besher on 2018-12-30.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import UIKit

// Fast GPU
class FreedrawingImageView: UIImageView, DrawingSpace {
    
    var autoPoints = [CGPoint]()
    var line = [CGPoint]()
    var currentTouchPosition: CGPoint?
    var displayLink: CADisplayLink?
    
    // this is where we store the drawn shape
    var _layerDump: CALayer?
    
    var layerDump: CALayer? {
        get {
            if _layerDump == nil {
                _layerDump = setupLayerDump()
            }
            return _layerDump
        }
        set {
            _layerDump = newValue
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        isUserInteractionEnabled = true
    }
    
    func setupLayerDump() -> CALayer {
        let sublayer = CALayer()
        sublayer.contentsScale = Display.scale
        layer.addSublayer(sublayer)
        return sublayer
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let newTouchPoint = touches.first?.location(in: self) else { return }
        
        currentTouchPosition = newTouchPoint
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        guard let newTouchPoint = touches.first?.location(in: self) else { return }
        guard let previousTouchPoint = currentTouchPosition else { return }
        stopDrawing()
        drawBezier(from: previousTouchPoint, to: newTouchPoint)
        currentTouchPosition = newTouchPoint
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        convertBezierToImage()
        currentTouchPosition = nil
    }
    
    func drawBezier(from start: CGPoint, to end: CGPoint) {
        let line = CAShapeLayer()
        let linePath = UIBezierPath()
        layerDump?.contentsScale = Display.scale
        line.contentsScale = Display.scale
        linePath.move(to: start)
        linePath.addLine(to: end)
        line.path = linePath.cgPath
        line.fillColor = lineColor.cgColor
        line.opacity = 1
        line.lineWidth = lineWidth
        line.lineCap = .round
        line.strokeColor = lineColor.cgColor
        layerDump?.addSublayer(line)
        
        if let count = layerDump?.sublayers?.count, count > 400 {
            convertBezierToImage()
        }
    }
    
    func convertBezierToImage() {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, Display.scale)
        if let context = UIGraphicsGetCurrentContext() {
            
            // keep old drawings
            if let image = self.image {
                image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
            }
            
            // add new drawings
            layerDump?.render(in: context)
            
            let output = UIGraphicsGetImageFromCurrentImageContext()
            self.image = output
        }
        clearSublayers()
        UIGraphicsEndImageContext()
    }
    
    func clearSublayers() {
        layerDump?.removeFromSuperlayer()
        layerDump = nil
    }
    
    func drawSpiral() {
        let link = CADisplayLink(target: self, selector: #selector(drawSpiralLink))
        link.add(to: .main, forMode: .default)
        displayLink = link
    }
    
    @objc func drawSpiralLink() {
        if self.autoPoints.isEmpty {
            self.createSpiral()
            self.currentTouchPosition = nil
        } else {
            let previousPoint = self.currentTouchPosition ?? self.autoPoints.removeFirst()
            let newPoint = self.autoPoints.removeFirst()
            
            self.drawBezier(from: previousPoint, to: newPoint)
            
            self.currentTouchPosition = newPoint
        }
    }
    
    func clear() {
        displayLink?.invalidate()
        displayLink = nil
        clearSublayers()
        autoPoints.removeAll()
        image = nil
    }
    
    func flattenImage() {}
    func checkIfTooManyPointsIn(_ line: inout [CGPoint]) {}
}
