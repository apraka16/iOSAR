//
//  CubeView.swift
//  ARKitBasics
//
//  Created by Abhinav Prakash on 28/10/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit

class CubeView: UIView {
    
    private var color: UIColor = UIColor.red

    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        let path = UIBezierPath(rect: CGRect(x: 1.0, y: 1.0, width: 0.1, height: 0.1))
        path.lineWidth = 0.1
        color.set()
        path.stroke()
    }
}
