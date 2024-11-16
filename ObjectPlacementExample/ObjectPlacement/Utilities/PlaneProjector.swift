/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
A utility for projecting points in space onto nearby planes.
*/

import Foundation
import ARKit
import RealityKit

enum PlaneProjector {
    /// Projects a given point onto a nearby horizontal plane from a given set of planes.
    static func project(point originFromPointTransform: matrix_float4x4,
                        ontoHorizontalPlaneIn planeAnchors: [PlaneAnchor],
                        withMaxDistance: Float) -> matrix_float4x4? {
        // 1. Only consider planes that are horizontal.
        let horizontalPlanes = planeAnchors.filter({ $0.alignment == .horizontal })
        
        // 2. Only consider planes that are within the given maximum distance.
        let inVerticalRangePlanes = horizontalPlanes.within(meters: withMaxDistance, of: originFromPointTransform)
        
        // 3. Only consider planes where the given point, projected onto the plane, is inside the plane’s geometry.
        let matchingPlanes = inVerticalRangePlanes.containing(pointToProject: originFromPointTransform)
        
        // 4. Of all matching planes, pick the closest one.
        if let closestPlane = matchingPlanes.closestPlane(to: originFromPointTransform) {
            // Return the given point’s transform with the position on y-axis changed to
            // the Y value of the closest horizontal plane.
            var result = originFromPointTransform
            result.translation = [originFromPointTransform.translation.x,
                                  closestPlane.originFromAnchorTransform.translation.y,
                                  originFromPointTransform.translation.z]
            return result
        }
        return nil
    }
}

extension Array where Element == PlaneAnchor {
    /// Filters this array of horizontal plane anchors for those planes that are within a given maximum distance in meters from a given point.
    func within(meters maxDistance: Float, of originFromGivenPointTransform: matrix_float4x4) -> [PlaneAnchor] {
        var matchingPlanes: [PlaneAnchor] = []
        let originFromGivenPointY = originFromGivenPointTransform.translation.y
        for anchor in self {
            let originFromPlaneY = anchor.originFromAnchorTransform.translation.y
            let distance = abs(originFromGivenPointY - originFromPlaneY)
            if distance <= maxDistance {
                matchingPlanes.append(anchor)
            }
        }
        return matchingPlanes
    }
    
    /// Finds the plane that's closest to the given point on the y-axis from an array of horizontal plane anchors.
    func closestPlane(to originFromGivenPointTransform: matrix_float4x4) -> PlaneAnchor? {
        var shortestDistance = Float.greatestFiniteMagnitude
        var closestPlane: PlaneAnchor?
        let originFromGivenPointY = originFromGivenPointTransform.translation.y
        for anchor in self {
            let originFromPlaneY = anchor.originFromAnchorTransform.translation.y
            let distance = abs(originFromGivenPointY - originFromPlaneY)
            if distance < shortestDistance {
                shortestDistance = distance
                closestPlane = anchor
            }
        }
        return closestPlane
    }
    
    /// Filters an array of horizontal plane anchors for those planes where a given point, projected onto the plane, is inside the plane’s geometry,
    func containing(pointToProject originFromGivenPointTransform: matrix_float4x4) -> [PlaneAnchor] {
        var matchingPlanes: [PlaneAnchor] = []
        for anchor in self {
            // 1. Project the given point into the plane’s 2D coordinate system.
            let planeAnchorFromOriginTransform = simd_inverse(anchor.originFromAnchorTransform)
            let planeAnchorFromPointTransform = planeAnchorFromOriginTransform * originFromGivenPointTransform
            let planeAnchorFromPoint2D: SIMD2<Float> = [planeAnchorFromPointTransform.translation.x, planeAnchorFromPointTransform.translation.z]
            
            var insidePlaneGeometry = false

            // 2. For each triangle of the plane geometry, check whether the given point lies inside of the triangle.
            let faceCount = anchor.geometry.meshFaces.count
            for faceIndex in 0 ..< faceCount {
                let vertexIndicesForThisFace = anchor.geometry.meshFaces[faceIndex]
                let vertex1 = anchor.geometry.meshVertices[vertexIndicesForThisFace[0]]
                let vertex2 = anchor.geometry.meshVertices[vertexIndicesForThisFace[1]]
                let vertex3 = anchor.geometry.meshVertices[vertexIndicesForThisFace[2]]

                insidePlaneGeometry = planeAnchorFromPoint2D.isInsideOf([vertex1.0, vertex1.2], [vertex2.0, vertex2.2], [vertex3.0, vertex3.2])
                if insidePlaneGeometry {
                    matchingPlanes.append(anchor)
                    break
                }
            }
        }
        return matchingPlanes
    }
}
