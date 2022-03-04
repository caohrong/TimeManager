//
//  HRMapView.swift
//  TimeManager
//
//  Created by Huanrong on 3/6/19.
//  Copyright © 2019 Huanrong. All rights reserved.
//

import MapKit
import UIKit

class HRMapView: UIView, MKMapViewDelegate {
    let mapView: MKMapView = {
        let mapView = MKMapView(frame: CGRect.zero)
        mapView.mapType = MKMapType.standard

        return mapView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = UIColor.lightGray

        mapView.backgroundColor = UIColor.blue
        addSubview(mapView)

        translatesAutoresizingMaskIntoConstraints = false
        mapView.translatesAutoresizingMaskIntoConstraints = false

        mapView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        mapView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        mapView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        mapView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
