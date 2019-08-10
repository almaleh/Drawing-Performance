//
//  FreeDrawingImageView.swift
//
//  Created by Besher on 2018-12-30.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import UIKit

// Draw GPU
class FreeDrawingImageViewDrawLayer: UIView, Drawable {
    
    var drawingLayer: CAShapeLayer?
    var displayLink: CADisplayLink?
    var timer: Timer?
    var line = [CGPoint]() {
        didSet { checkIfTooManyPoints() }
    }
    
    var sublayers: [CALayer] {
        return self.layer.sublayers ?? [CALayer]()
    }
    
    var spiralPoints = [CGPoint]()
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let newTouchPoint = touches.first?.location(in: self) else { return }
        stopAutoDrawing()
        line.append(newTouchPoint)
        
        let lastTouchPoint: CGPoint = line.last ?? .zero
        
        let rect = calculateRectBetween(lastPoint: lastTouchPoint, newPoint: newTouchPoint)
        
        layer.setNeedsDisplay(rect)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        flattenImage()
    }
    
    override func draw(_ layer: CALayer, in ctx: CGContext) {
        
        let drawingLayer = self.drawingLayer ?? CAShapeLayer()
        let linePath = UIBezierPath()
        drawingLayer.contentsScale = Display.scale
        
        for (index, point) in line.enumerated() {
            if index == 0 {
                linePath.move(to: point)
            } else {
                linePath.addLine(to: point)
            }
        }
        drawingLayer.path = linePath.cgPath
        drawingLayer.opacity = 1
        drawingLayer.lineWidth = lineWidth
        drawingLayer.lineCap = .round
        drawingLayer.lineJoin = .round
        drawingLayer.fillColor = UIColor.clear.cgColor
        drawingLayer.strokeColor = lineColor.cgColor
        
        if self.drawingLayer == nil {
            self.drawingLayer = drawingLayer
            layer.addSublayer(drawingLayer)
        }
    }
    
    func checkIfTooManyPoints() {
        let maxPoints = 25
        if line.count > maxPoints {
            updateFlattenedLayer()
            // we leave two points to ensure no gaps or sharp angles
            _ = line.removeFirst(maxPoints - 2)
        }
    }
    
    func flattenImage() {
        updateFlattenedLayer()
        line.removeAll()
    }
    
    func updateFlattenedLayer() {
        // 1
        guard let drawingLayer = drawingLayer,
            // 2
            let optionalDrawing = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(
                NSKeyedArchiver.archivedData(withRootObject: drawingLayer, requiringSecureCoding: false))
                as? CAShapeLayer,
            // 3
            let newDrawing = optionalDrawing else { return }
        // 4
        layer.addSublayer(newDrawing)
    }
    
    func drawSpiralWithLink() {
        let link = CADisplayLink(target: self, selector: #selector(drawSpiral))
        link.add(to: .main, forMode: .default)
        displayLink = link
    }
    
    @objc func drawSpiral() {
        if self.spiralPoints.isEmpty {
            emptyFlattenedLayers()
            drawingLayer?.removeFromSuperlayer()
            drawingLayer = nil
            line.removeAll()
            spiralPoints.removeAll()
            layer.setNeedsDisplay()
            self.createSpiral()
            self.flattenImage()
        } else {
            self.line.append(self.spiralPoints.removeFirst())
            self.layer.setNeedsDisplay()
            self.checkIfTooManyPoints()
        }
    }
    
    func clear() {
        stopAutoDrawing()
        emptyFlattenedLayers()
        drawingLayer?.removeFromSuperlayer()
        drawingLayer = nil
        line.removeAll()
        spiralPoints.removeAll()
        layer.setNeedsDisplay()
    }
    
    func emptyFlattenedLayers() {
        for case let layer as CAShapeLayer in sublayers {
            layer.removeFromSuperlayer()
        }
    }
}
