//
//  DisplayedViewEnum.swift
//  Drawing Performance
//
//  Created by Besher on 2019-01-13.
//  Copyright © 2019 Besher Al Maleh. All rights reserved.
//

import Foundation

enum DisplayedView {
    case cpuSlow(Drawable)
    case cpuFast(Drawable)
    case gpuDrawLayer(Drawable)
    case gpuSubLayer(Drawable)
    
    var associatedView: Drawable {
        switch self {
        case .cpuSlow(let view): return view
        case .cpuFast(let view): return view
        case .gpuDrawLayer(let view): return view
        case .gpuSubLayer(let view): return view
        }
    }
}
