//
//  SphereNode.swift
//  ObjectDetection-CoreML
//
//  Created by BHSoft on 12/09/2022.
//  Copyright © 2022 tucan9389. All rights reserved.
//

import Foundation
import SceneKit

class SphereNode: SCNNode {
    init(position: SIMD3<Float>) {
        super.init()
        let sphereGeometry = SCNSphere(radius: 0.005)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        material.lightingModel = .physicallyBased
        sphereGeometry.materials = [material]
        self.geometry = sphereGeometry
        self.simdTransform.translation = position
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
