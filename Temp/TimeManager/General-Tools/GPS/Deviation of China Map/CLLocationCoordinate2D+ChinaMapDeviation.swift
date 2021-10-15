//
//  CLLocationCoordinate2D+ChinaMapDeviation.swift
//  TimeManager
//
//  Created by Huanrong on 4/10/19.
//  Copyright © 2019 Huanrong. All rights reserved.
//

import Foundation

extension CLLocationCoordinate2D {
    func deviatedCoordinates() -> CLLocationCoordinate2D {
        let location = CLLocation(latitude: self.latitude, longitude: self.longitude)
        return location.deviatedCoordinates()
    }
    func unDeviatedCoordinates() -> CLLocationCoordinate2D {
        let location = CLLocation(latitude: self.latitude, longitude: self.longitude)
        return location.undeviatedCoordinates()
    }
}
