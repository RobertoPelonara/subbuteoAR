//
//  Extensions.swift
//  ARLearning
//
//  Created by Antonio Sirica on 08/02/2018.
//  Copyright © 2018 Antonio Sirica. All rights reserved.
//

import Foundation
import SceneKit

extension float4x4 {
    /**
     Ritrova e setta la posizione dalla matrice originale
     */
    var position: float3 {
        get {
            let translation = columns.3
            return float3(translation.x, translation.y, translation.z)
        }
        set(newValue) {
            columns.3 = float4(newValue.x, newValue.y, newValue.z, columns.3.w)
        }
    }
    
    /**
     Factors out the orientation component of the transform.
     */
    var orientation: simd_quatf {
        return simd_quaternion(self)
    }
    
    /**
     Ritrova e setta il valore scale dalla matrice originale
     */
    var scale: float3 {
        get {
            return float3(columns.0.x, columns.1.y, columns.2.z)
        }
        set {
            columns.0.x = newValue.x
            columns.1.y = newValue.y
            columns.2.z = newValue.z
        }
    }
}

