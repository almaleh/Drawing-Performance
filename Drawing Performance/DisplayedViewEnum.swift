//
//  DisplayedViewEnum.swift
//  Drawing Performance
//
//  Created by Besher on 2019-01-13.
//  Copyright © 2019 Besher Al Maleh. All rights reserved.
//

import Foundation

enum DisplayedView {
    case cpuSlow(DrawingSpace)
    case cpuFast(DrawingSpace)
    case gpuSlow(DrawingSpace)
    case gpuFast(DrawingSpace)
    
    var associatedView: DrawingSpace {
        switch self {
        case .cpuSlow(let view): return view
        case .cpuFast(let view): return view
        case .gpuSlow(let view): return view
        case .gpuFast(let view): return view
        }
    }
}
