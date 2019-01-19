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
    case gpuSlow(Drawable)
    case gpuFast(Drawable)
    
    var associatedView: Drawable {
        switch self {
        case .cpuSlow(let view): return view
        case .cpuFast(let view): return view
        case .gpuSlow(let view): return view
        case .gpuFast(let view): return view
        }
    }
}
