//
//  ViewController.swift
//  Drawing Performance
//
//  Created by Besher on 2019-01-13.
//  Copyright © 2019 Besher Al Maleh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var fpsLabel: UILabel!
    @IBOutlet weak var drawingContainer: UIView!
    
    let fpsCounter = FPSCounter()
    
    lazy var cpuSlowView: FreedrawingImageViewCG = setupView()
    lazy var cpuFastView: FreedrawingImageViewDrawRect = setupView()
    lazy var gpuSlowView: FreeDrawingImageViewDrawLayer = setupView()
    lazy var gpuFastView: FreedrawingImageView = setupView()
    
    lazy var allViews: [DrawingSpace] = [cpuSlowView, cpuFastView, gpuSlowView, gpuFastView]
    
    var displayedView: DisplayedView? {
        didSet { show(displayedView) }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fpsCounter.delegate = self
        fpsCounter.startTracking()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cpuSlowView.backgroundColor = .green
        cpuFastView.backgroundColor = .blue
        gpuSlowView.backgroundColor = .brown
        gpuFastView.backgroundColor = .purple
        
        displayedView = .cpuSlow(cpuSlowView)
    }
    
    @IBAction func startDrawing(_ sender: UIBarButtonItem) {
        displayedView?.associatedView.startAutoDrawing()
    }
    
    @IBAction func clearCanvas(_ sender: UIBarButtonItem) {
        displayedView?.associatedView.clear()
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: displayedView = .cpuSlow(cpuSlowView)
        case 1: displayedView = .gpuSlow(gpuSlowView)
        case 2: displayedView = .cpuFast(cpuFastView)
        case 3: displayedView = .gpuFast(gpuFastView)
        default: break
        }
    }
    
    func show(_ view: DisplayedView?) {
        guard let view = view else { return }
        allViews.forEach { $0.hide() }
        view.associatedView.unHide()
    }
    
    func setupView<T: UIView>() -> T {
        let view = T()
        view.bounds = drawingContainer.bounds
        view.frame.origin = .zero
        view.isHidden = true
        drawingContainer.addSubview(view)
        return view
    }
}

extension ViewController: FPSCounterDelegate {
    func fpsCounter(_ counter: FPSCounter, didUpdateFramesPerSecond fps: Int) {
        fpsLabel.text = "FPS \(fps)"
    }
}
