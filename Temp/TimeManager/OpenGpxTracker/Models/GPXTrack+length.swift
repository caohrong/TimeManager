//
//  GPXTrack+length.swift
//  OpenGpxTracker
//
//  Created by merlos on 30/09/15.
//

import CoreGPX
import Foundation
import MapKit

/// Extension to support getting the distance of a track in meters.
public extension GPXTrack {
    /// Track length in meters
    var length: CLLocationDistance {
        var trackLength: CLLocationDistance = 0.0
        for segment in tracksegments {
            trackLength += segment.length()
        }
        return trackLength
    }
}
