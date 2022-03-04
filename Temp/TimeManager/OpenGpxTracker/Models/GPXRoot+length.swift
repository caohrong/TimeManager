//
//  GPXRoot+length.swift
//  OpenGpxTracker
//
//  Created by merlos on 01/10/15.
//

import CoreGPX
import Foundation
import MapKit

/// Extends GPXRoot to support getting the length of all tracks in meters
public extension GPXRoot {
    /// Distance in meters of all the track segments
    var tracksLength: CLLocationDistance {
        var tLength: CLLocationDistance = 0.0
        for track in tracks {
            tLength += track.length
        }
        return tLength
    }
}
