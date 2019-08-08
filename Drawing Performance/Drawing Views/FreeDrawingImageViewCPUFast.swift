//
//  FreeDrawingImageView.swift
//
//  Created by Besher on 2018-12-30.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import UIKit

// Fast CPU
class FreedrawingImageViewDrawRect: UIView, Drawable {
    
    var spiralPoints = [CGPoint]()
    var flattenedImage: UIImage?
    var displayLink: CADisplayLink?
    var timer: Timer? 
    var line = [CGPoint]() {
        didSet {
            checkIfTooManyPointsIn(&line)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let newTouchPoint = touches.first?.location(in: self) else { return }
        
        let lastTouchPoint: CGPoint = line.last ?? .zero
        stopAutoDrawing()
        line.append(newTouchPoint)
        
        let rect = calculateRectBetween(lastPoint: lastTouchPoint, newPoint: newTouchPoint)
        
        setNeedsDisplay(rect)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        flattenImage()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // draw the flattened image if it exists
        if let image = flattenedImage {
            image.draw(in: self.bounds)
        }
        
        context.setStrokeColor(lineColor.cgColor)
        context.setLineWidth(lineWidth)
        context.setLineCap(.round)
        context.setLineJoin(.round)
        
        for (index, point) in line.enumerated() {
            if index == 0 {
                context.move(to: point)
            } else {
                context.addLine(to: point)
            }
        }
        context.strokePath()
    }
    
    func checkIfTooManyPointsIn(_ line: inout [CGPoint]) {
        let maxPoints = 200
        if line.count > maxPoints {
            flattenedImage = self.getImageRepresentation()
            
            // we leave one point to ensure no gaps in drawing
            _ = line.removeFirst(maxPoints - 1)
        }
    }
    
    func flattenImage() {
        flattenedImage = self.getImageRepresentation()
        line.removeAll()
    }
    
    func drawSpiralWithLink() {
        let link = CADisplayLink(target: self, selector: #selector(drawSpiral))
        link.add(to: .main, forMode: .default)
        displayLink = link
    }
    
    @objc func drawSpiral() {
        if self.spiralPoints.isEmpty {
            self.createSpiral()
            self.flattenImage()
        } else {
            self.line.append(spiralPoints.removeFirst())
            self.layer.setNeedsDisplay()
            self.checkIfTooManyPointsIn(&line)
        }
    }
    
    func clear() {
        stopAutoDrawing()
        flattenedImage = nil
        line.removeAll()
        spiralPoints.removeAll()
        setNeedsDisplay()
    }
}
