//
//  HRMapView.swift
//  TimeManager
//
//  Created by Huanrong on 3/6/19.
//  Copyright © 2019 Huanrong. All rights reserved.
//

import UIKit
import MapKit

class HRMapView: UIView, MKMapViewDelegate {
    let mapView:MKMapView = {
        let mapView = MKMapView(frame: CGRect.zero)
        mapView.mapType = MKMapType.standard
        
        return mapView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.lightGray
        
        mapView.backgroundColor = UIColor.blue
        self.addSubview(mapView)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        mapView.translatesAutoresizingMaskIntoConstraints = false

        mapView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        mapView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
        mapView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        mapView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
