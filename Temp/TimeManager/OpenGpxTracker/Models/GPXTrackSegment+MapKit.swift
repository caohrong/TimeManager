//
//  GPXTrackSegment+MapKit.swift
//  OpenGpxTracker
//
//  Created by merlos on 20/09/14.
//

import CoreGPX
import Foundation
import MapKit
import UIKit

//
// This extension adds some methods to work with mapkit
//
#if os(iOS)
    public extension GPXTrackSegment {
        // Returns a mapkit polyline with the points of the segment.
        // This polyline can be directly plotted on the map as an overlay
        var overlay: MKPolyline {
            var coords: [CLLocationCoordinate2D] = trackPointsToCoordinates()
            let pl = MKPolyline(coordinates: &coords, count: coords.count)
            return pl
        }
    }
#endif

extension GPXTrackSegment {
    // Helper method to create the polyline. Returns the array of coordinates of the points
    // that belong to this segment
    func trackPointsToCoordinates() -> [CLLocationCoordinate2D] {
        var coords: [CLLocationCoordinate2D] = []

        for point in trackpoints {
            coords.append(point.coordinate)
        }
        return coords
    }

    // Calculates length in meters of the segment
    func length() -> CLLocationDistance {
        var length: CLLocationDistance = 0.0
        var distanceTwoPoints: CLLocationDistance
        // we need at least two points
        if trackpoints.count < 2 {
            return length
        }
        var prev: CLLocation? // previous
        for point in trackpoints {
            let pt = CLLocation(latitude: Double(point.latitude!), longitude: Double(point.longitude!))
            if prev == nil { // if first point => set it as previous and go for next
                prev = pt
                continue
            }
            distanceTwoPoints = pt.distance(from: prev!)
            length += distanceTwoPoints
            // set current point as previous point
            prev = pt
        }
        return length
    }
}
