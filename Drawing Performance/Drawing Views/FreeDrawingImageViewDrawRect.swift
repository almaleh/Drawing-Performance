//
//  FreeDrawingImageView.swift
//
//  Created by Besher on 2018-12-30.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import UIKit

// Fast CPU
class FreedrawingImageViewDrawRect: UIView, DrawingSpace {
    
    var autoPoints = [CGPoint]()
    var flattenedImage: UIImage?
    var displayLink: CADisplayLink?
    var line = [CGPoint]() {
        didSet {
            checkIfTooManyPointsIn(&line)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let newTouchPoint = touches.first?.location(in: self) else { return }
        
        let lastTouchPoint: CGPoint = line.last ?? .zero
        stopDrawing()
        line.append(newTouchPoint)
        
        let rect = calculateRectBetween(lastPoint: lastTouchPoint, newPoint: newTouchPoint)
        
        setNeedsDisplay(rect)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
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
    
    func drawSpiral() {
        let link = CADisplayLink(target: self, selector: #selector(drawSpiralLink))
        link.add(to: .main, forMode: .default)
        displayLink = link
    }
    
    @objc func drawSpiralLink() {
        if self.autoPoints.isEmpty {
            self.createSpiral()
            self.flattenImage()
        } else {
            self.line.append(self.autoPoints.removeFirst())
            self.layer.setNeedsDisplay()
            self.checkIfTooManyPointsIn(&self.line)
        }
    }
    
    func calculateRectBetween(lastPoint: CGPoint, newPoint: CGPoint) -> CGRect {
        var rect = CGRect.zero
        
        let originX = min(lastPoint.x, newPoint.x) - (lineWidth / 2)
        let originY = min(lastPoint.y, newPoint.y) - (lineWidth / 2)
        
        let maxX = max(lastPoint.x, newPoint.x) + (lineWidth / 2)
        let maxY = max(lastPoint.y, newPoint.y) + (lineWidth / 2)
        
        let width = maxX - originX
        let height = maxY - originY
        
        rect = CGRect(x: originX, y: originY, width: width, height: height)
        
        return rect
    }
    
    func getImageRepresentation() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.isOpaque, 0.0)
        defer { UIGraphicsEndImageContext() }
        if let context = UIGraphicsGetCurrentContext() {
            self.layer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            return image
        }
        return nil
    }
    
    func clear() {
        flattenedImage = nil
        line.removeAll()
        autoPoints.removeAll()
        setNeedsDisplay()
    }
}
