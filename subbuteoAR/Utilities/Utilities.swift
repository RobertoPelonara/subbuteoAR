/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Utility functions and type extensions used throughout the projects.
*/

import Foundation
import ARKit
import QuartzCore

extension Float {

    func map(from: ClosedRange<CGFloat>, to: ClosedRange<CGFloat>) -> Float {
        return Float(CGFloat(self).map(from: from, to: to))
    }
}




// MARK: - float4x4 extensions

extension float4x4 {
    /**
     Treats matrix as a (right-hand column-major convention) transform matrix
     and factors out the translation component of the transform.
    */
    var translation: float3 {
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
     Creates a transform matrix with a uniform scale factor in all directions.
     */
    init(uniformScale scale: Float) {
        self = matrix_identity_float4x4
        columns.0.x = scale
        columns.1.y = scale
        columns.2.z = scale
    }
}

// MARK: - CGPoint extensions

extension CGPoint {
    /// Extracts the screen space point from a vector returned by SCNView.projectPoint(_:).
	init(_ vector: SCNVector3) {
        self.init(x: CGFloat(vector.x), y: CGFloat(vector.y))
	}

    /// Returns the length of a point when considered as a vector. (Used with gesture recognizers.)
    var length: CGFloat {
		return sqrt(x * x + y * y)
	}
    
    
}

extension CGFloat {
    func map(from from: ClosedRange<CGFloat>, to: ClosedRange<CGFloat>) -> CGFloat {
        let result = ((self - from.upperBound) / (from.lowerBound - from.upperBound)) * (to.lowerBound - to.upperBound) + to.upperBound
        return result
    }
}

// MARK: - Vector Operations

extension SCNVector3: Codable {
    /**
     Ritorna il modulo del vettore
     */
    func length() -> Float {
        return sqrtf(x*x + y*y + z*z)
    }
    
    /**
     Ritorna un vettore normalizzato senza cambiare l'originale
     */
    func normalized() -> SCNVector3 {
        return self / length()
    }
    
    
    /**
     Normalizza il vettore e ritorna il valore.
     */
    mutating func normalize() {
        self = normalized()
    }
    
    /**
     Calcola la distanza tra due vettori con Pitagora!
     */
    func distance(vector: SCNVector3) -> Float {
        return (self - vector).length()
    }
    
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.x = try container.decode(Float.self)
        self.y = try container.decode(Float.self)
        self.z = try container.decode(Float.self)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(self.x)
        try container.encode(self.y)
        try container.encode(self.z)
    }

    
}
/**
 Implementa la differenza tra due vettori
 */
func - (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x - right.x,
                          left.y - right.y,
                          left.z - right.z)
}

/**
Implementa la distanza tra due CGPoint
 */
func distance (pointA: CGPoint, pointB: CGPoint) -> Float {
    let direction = CGPoint(x: pointA.x - pointB.x,
                            y: pointA.y - pointB.y)
    let lenght = sqrtf(Float((direction.x * direction.x) + (direction.y * direction.y)))
    return lenght
}

/**
 implementa la divisione per scalari
 */
func / (vector: SCNVector3, scalar: Float) -> SCNVector3 {
    return SCNVector3Make(vector.x / scalar, vector.y / scalar, vector.z / scalar)
}

/**
 Implementa la moltiplicazioni per scalari
 */
func * (vector: SCNVector3, scalar: Float) -> SCNVector3 {
    return SCNVector3Make(vector.x * scalar,
                          vector.y * scalar,
                          vector.z * scalar)
}
