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
    @IBOutlet weak var descriptionLabel: UILabel!
    
    let fpsCounter = FPSCounter()
    
    lazy var cpuSlowView: FreedrawingImageViewCG = setupView()
    lazy var cpuFastView: FreedrawingImageViewDrawRect = setupView()
    lazy var gpuDrawLayer: FreeDrawingImageViewDrawLayer = setupView()
    lazy var gpuSubLayer: FreedrawingImageView = setupView()
    
    lazy var allViews: [Drawable] = [cpuSlowView, cpuFastView, gpuDrawLayer, gpuSubLayer]
    
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
        gpuDrawLayer.backgroundColor = .orange
        gpuSubLayer.backgroundColor = .purple
        
        displayedView = .cpuSlow(cpuSlowView)
    }
    
    @IBAction func startDrawingLink(_ sender: UIBarButtonItem) {
        displayedView?.associatedView.startAutoDrawingLink()
    }
    
    @IBAction func startDrawingTimer(_ sender: UIBarButtonItem) {
        displayedView?.associatedView.startAutoDrawingTimer()
    }
    
    @IBAction func clearCanvas(_ sender: UIBarButtonItem) {
        displayedView?.associatedView.clear()
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: displayedView = .cpuSlow(cpuSlowView)
        case 1: displayedView = .cpuFast(cpuFastView)
        case 2: displayedView = .gpuDrawLayer(gpuSubLayer)
        case 3: displayedView = .gpuSubLayer(gpuDrawLayer)
        default: break
        }
    }
    
    func show(_ view: DisplayedView?) {
        guard let view = view else { return }
        allViews.forEach { $0.hide() }
        view.associatedView.unHide()
        descriptionLabel.text = view.description
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
