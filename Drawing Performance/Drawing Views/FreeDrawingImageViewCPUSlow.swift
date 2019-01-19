//
//  FreeDrawingImageView.swift
//
//  Created by Besher on 2018-12-30.
//  Copyright © 2018 Besher Al Maleh. All rights reserved.
//

import UIKit

// Slow CPU
class FreedrawingImageViewCG: UIImageView, Drawable {
    
    var spiralPoints = [CGPoint]()
    var currentTouchPosition: CGPoint?
    var displayLink: CADisplayLink?
    var timer: Timer? 
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        isUserInteractionEnabled = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let newTouchPoint = touches.first?.location(in: self) else { return }
        currentTouchPosition = newTouchPoint
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let newTouchPoint = touches.first?.location(in: self) else { return }
        guard let previousTouchPoint = currentTouchPosition else { return }
        stopAutoDrawing()
        draw(from: previousTouchPoint, to: newTouchPoint)
        
        currentTouchPosition = newTouchPoint
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        currentTouchPosition = nil
    }
    
    func draw(from start: CGPoint, to end: CGPoint) {
        let renderer = UIGraphicsImageRenderer(size: bounds.size)
        
        image = renderer.image { ctx in
            image?.draw(in: bounds)
            
            lineColor.setStroke()
            
            ctx.cgContext.setLineCap(.round)
            ctx.cgContext.setLineWidth(lineWidth)
            ctx.cgContext.move(to: start)
            ctx.cgContext.addLine(to: end)
            ctx.cgContext.strokePath()
        }
    }
    
    func drawSpiralWithLink() {
        let link = CADisplayLink(target: self, selector: #selector(drawSpiral))
        link.add(to: .main, forMode: .default)
        displayLink = link
    }
    
    @objc func drawSpiral() {
        if self.spiralPoints.isEmpty {
            self.createSpiral()
            self.currentTouchPosition = nil
        } else {
            let previousPoint = self.currentTouchPosition ?? self.spiralPoints.removeFirst()
            let newPoint = self.spiralPoints.removeFirst()
            
            self.draw(from: previousPoint, to: newPoint)
            
            self.currentTouchPosition = newPoint
        }
    }
    
    func clear() {
        spiralPoints.removeAll()
        image = nil
        stopAutoDrawing()
    }
}
