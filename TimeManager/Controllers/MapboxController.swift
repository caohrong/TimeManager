//
//  MapboxController.swift
//  TimeManager
//
//  Created by Huanrong on 4/10/19.
//  Copyright © 2019 Huanrong. All rights reserved.
//
import Mapbox
import CoreGPX
class MapboxController: UIViewController, MGLMapViewDelegate {
    var mapView: MGLMapView!
    var timer: Timer?
    var polylineSource: MGLShapeSource?
    var currentIndex = 1
    var allCoordinates: [CLLocationCoordinate2D]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Trip to ShangHai"
        
        mapView = MGLMapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        mapView.setCenter(
            CLLocationCoordinate2D(latitude: 39.863951615989208, longitude: 116.373084923252463),
            zoomLevel: 5,
            animated: false)
        view.addSubview(mapView)
        
        mapView.delegate = self
        
        allCoordinates = coordinates
    }
    
    // Wait until the map is loaded before adding to the map.
    func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
        addPolyline(to: mapView.style!)
        animatePolyline()
    }
    
    func addPolyline(to style: MGLStyle) {
        // Add an empty MGLShapeSource, we’ll keep a reference to this and add points to this later.
        let source = MGLShapeSource(identifier: "polyline", shape: nil, options: nil)
        style.addSource(source)
        polylineSource = source
        
        // Add a layer to style our polyline.
        let layer = MGLLineStyleLayer(identifier: "polyline", source: source)
        layer.lineJoin = NSExpression(forConstantValue: "round")
        layer.lineCap = NSExpression(forConstantValue: "round")
        layer.lineColor = NSExpression(forConstantValue: UIColor.red)
        
        // The line width should gradually increase based on the zoom level.
        layer.lineWidth = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)",
                                       [14: 5, 18: 20])
        style.addLayer(layer)
    }
    
    func animatePolyline() {
        currentIndex = 1
        
        // Start a timer that will simulate adding points to our polyline. This could also represent coordinates being added to our polyline from another source, such as a CLLocationManagerDelegate.
        timer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
    }
    
    @objc func tick() {
        if currentIndex > allCoordinates.count {
            timer?.invalidate()
            timer = nil
            return
        }
        
        // Create a subarray of locations up to the current index.
        let coordinates = Array(allCoordinates[0..<currentIndex])
        
        // Update our MGLShapeSource with the current locations.
        updatePolylineWithCoordinates(coordinates: coordinates)
        
        currentIndex += 1
    }
    
    func updatePolylineWithCoordinates(coordinates: [CLLocationCoordinate2D]) {
        var mutableCoordinates = coordinates
        
        let polyline = MGLPolylineFeature(coordinates: &mutableCoordinates, count: UInt(mutableCoordinates.count))
        
        // Updating the MGLShapeSource’s shape will have the map redraw our polyline with the current coordinates.
        polylineSource?.shape = polyline
    }
    
    var coordinates:[CLLocationCoordinate2D] {
        get {
            if let gpxFile = Bundle.main.url(forResource: "北京-上海", withExtension: "GPX"),
                let gpx = GPXParser(withURL: gpxFile)?.parsedData(),
                let track = gpx.tracks.first?.tracksegments.first {
                let coordinates =  track.trackpoints.map { (point) -> CLLocationCoordinate2D in
                    return CLLocationCoordinate2D.init(latitude: point.latitude ?? 0.0, longitude: point.longitude ?? 0.0)
                }
                return coordinates
            }
            return [CLLocationCoordinate2D]()
        }
    }
}
