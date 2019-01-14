//
//  FreeDrawingImageView.swift
//
//  Created by Besher on 2018-12-30.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import UIKit

// Fast GPU
class FreedrawingImageView: UIImageView, DrawingSpace {
    
    var spiralPoints = [CGPoint]()
    var line = [CGPoint]() // not used in this class
    var currentTouchPosition: CGPoint?
    var displayLink: CADisplayLink?
    
    // this is where we store the drawn shape
    var drawingLayer: CALayer?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        isUserInteractionEnabled = true
    }
    
    func setupDrawingLayerIfNeeded() {
        guard drawingLayer == nil else { return }
        let sublayer = CALayer()
        sublayer.contentsScale = Display.scale
        layer.addSublayer(sublayer)
        drawingLayer = sublayer
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
        stopAutoDrawing()
        drawBezier(from: previousTouchPoint, to: newTouchPoint)
        currentTouchPosition = newTouchPoint
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        flattenToImage()
        currentTouchPosition = nil
    }
    
    func drawBezier(from start: CGPoint, to end: CGPoint) {
        setupDrawingLayerIfNeeded()
        let line = CAShapeLayer()
        let linePath = UIBezierPath()
        line.contentsScale = Display.scale
        linePath.move(to: start)
        linePath.addLine(to: end)
        line.path = linePath.cgPath
        line.fillColor = lineColor.cgColor
        line.opacity = 1
        line.lineWidth = lineWidth
        line.lineCap = .round
        line.strokeColor = lineColor.cgColor
        
        drawingLayer?.addSublayer(line)
        
        if let count = drawingLayer?.sublayers?.count, count > 400 {
            flattenToImage()
        }
    }
    
    func flattenToImage() {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, Display.scale)
        if let context = UIGraphicsGetCurrentContext() {
            
            // keep old drawings
            if let image = self.image {
                image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
            }
            
            // add new drawings
            drawingLayer?.render(in: context)
            
            let output = UIGraphicsGetImageFromCurrentImageContext()
            self.image = output
        }
        clearSublayers()
        UIGraphicsEndImageContext()
    }
    
    func clearSublayers() {
        drawingLayer?.removeFromSuperlayer()
        drawingLayer = nil
    }
    
    func drawSpiral() {
        let link = CADisplayLink(target: self, selector: #selector(drawSpiralLink))
        link.add(to: .main, forMode: .default)
        displayLink = link
    }
    
    @objc func drawSpiralLink() {
        if self.spiralPoints.isEmpty {
            self.createSpiral()
            self.currentTouchPosition = nil
        } else {
            let previousPoint = self.currentTouchPosition ?? self.spiralPoints.removeFirst()
            let newPoint = self.spiralPoints.removeFirst()
            
            self.drawBezier(from: previousPoint, to: newPoint)
            
            self.currentTouchPosition = newPoint
        }
    }
    
    func clear() {
        displayLink?.invalidate()
        displayLink = nil
        clearSublayers()
        spiralPoints.removeAll()
        image = nil
    }
    
    func flattenImage() {}
    func checkIfTooManyPointsIn(_ line: inout [CGPoint]) {}
}
