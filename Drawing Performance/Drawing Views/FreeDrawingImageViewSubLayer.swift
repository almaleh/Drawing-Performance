//
//  FreeDrawingImageView.swift
//
//  Created by Besher on 2018-12-30.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import UIKit

// Sublayer GPU
class FreeDrawingImageViewSubLayer: UIImageView, Drawable {
    
    var spiralPoints = [CGPoint]()
    var currentTouchPosition: CGPoint?
    var displayLink: CADisplayLink?
    var timer: Timer?
    
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
        guard let newTouchPoint = touches.first?.location(in: self) else { return }
        currentTouchPosition = newTouchPoint
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
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
    
    func drawSpiralWithLink() {
        let link = CADisplayLink(target: self, selector: #selector(drawSpiral))
        link.add(to: .main, forMode: .default)
        displayLink = link
    }
    
    @objc func drawSpiral() {
        if spiralPoints.isEmpty {
            clearSublayers()
            spiralPoints.removeAll()
            image = nil
            currentTouchPosition = nil
            createSpiral()
        } else {
            let previousPoint = currentTouchPosition ?? spiralPoints.removeFirst()
            let newPoint = spiralPoints.removeFirst()
            
            drawBezier(from: previousPoint, to: newPoint)
            
            currentTouchPosition = newPoint
        }
    }
    
    func clear() {
        stopAutoDrawing()
        clearSublayers()
        spiralPoints.removeAll()
        image = nil
    }
}
