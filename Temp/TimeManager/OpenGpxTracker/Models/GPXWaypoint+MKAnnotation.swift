//
//  GPXPin.swift
//  OpenGpxTracker
//
//  Created by merlos on 16/09/14.
//

import CoreGPX
import Foundation
// import UIKit
import MapKit

extension GPXWaypoint: MKAnnotation {
    convenience init(coordinate: CLLocationCoordinate2D) {
        self.init(latitude: coordinate.latitude, longitude: coordinate.longitude)
        // set default title and subtitle

        // Default title now
        let timeFormat = DateFormatter()
        timeFormat.dateStyle = DateFormatter.Style.none
        timeFormat.timeStyle = DateFormatter.Style.medium
        // timeFormat.setLocalizedDateFormatFromTemplate("HH:mm:ss")

        let subtitleFormat = DateFormatter()
        // dateFormat.setLocalizedDateFormatFromTemplate("MMM dd, yyyy")
        subtitleFormat.dateStyle = DateFormatter.Style.medium
        subtitleFormat.timeStyle = DateFormatter.Style.medium

        let now = Date()
        time = now
        title = timeFormat.string(from: now)
        subtitle = subtitleFormat.string(from: now)
    }

    public var title: String? {
        set {
            name = newValue
        }
        get {
            return name
        }
    }

    public var subtitle: String? {
        set {
            desc = newValue
        }
        get {
            return desc
        }
    }

    public var coordinate: CLLocationCoordinate2D {
        set {
            latitude = newValue.latitude
            longitude = newValue.longitude
        }
        get {
            return CLLocationCoordinate2D(latitude: latitude!, longitude: CLLocationDegrees(longitude!))
        }
    }
}
