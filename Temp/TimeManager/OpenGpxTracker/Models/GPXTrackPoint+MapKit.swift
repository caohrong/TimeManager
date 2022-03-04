//
//  GPXPoint+MapKit.swift
//  OpenGpxTracker
//
//  Created by merlos on 20/09/14.
//

import CoreGPX
import Foundation
import MapKit
import UIKit

extension GPXTrackPoint {
    convenience init(location: CLLocation) {
        self.init()
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
        time = Date()
        elevation = location.altitude
    }
}
