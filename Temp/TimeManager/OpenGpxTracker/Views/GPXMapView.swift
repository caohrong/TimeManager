//
//  GPXMapView.swift
//  OpenGpxTracker
//
//  Created by merlos on 24/09/14.
//


import Foundation
import UIKit
import MapKit
import CoreGPX


/// GPX creator identifier. Used on generated files identify this app created them.
let kGPXCreatorString = "Open GPX Tracker for iOS"


///
/// A MapView that Tracks user position
///
/// - it is able to convert GPX file into map
/// - it is able to return a GPX file from map
///
///
/// ### Some definitions
///
/// 1. A **track** is a set of segments.
/// 2. A **segment** is set of points. A segment is linked to a MKPolyline overlay in the map.

/// Each time the user touches "Start Tracking" => a segment is created (currentSegment)
// Each time the users touches "Pause Tracking" => the segment is added to trackSegments
// When the user saves the file => trackSegments are consolidated in a single track that is
// added to the file.
// If the user opens the file in a session for the second, then tracks some segments and saves
// the file again, the resulting gpx file will have two tracks.
//
class GPXMapView: MKMapView {
    
    /// List of waypoints currently displayed on the map.
    var waypoints: [GPXWaypoint] = []
    
    /// List of tracks currently displayed on the map.
    var tracks: [GPXTrack] = []
    
    /// Current track segments
    var trackSegments: [GPXTrackSegment] = []
    
    /// Segment in which device locations are added.
    var currentSegment: GPXTrackSegment =  GPXTrackSegment()
    
    /// The line being displayed on the map that corresponds to the current segment.
    var currentSegmentOverlay: MKPolyline
    
    ///
    var extent: GPXExtentCoordinates = GPXExtentCoordinates() //extent of the GPX points and tracks
    
    /// Total tracked distance in meters
    var totalTrackedDistance = 0.00
    
    /// Distance in meters of current track (track in which new user positions are being added)
    var currentTrackDistance = 0.00
    
    /// Current segment distance in meters
    var currentSegmentDistance = 0.00

    ///position of the compass in the map
    ///Example:
    /// map.compassRect = CGRect(x: map.frame.width/2 - 18, y: 70, width: 36, height: 36)
    var compassRect : CGRect
    
    /// Is the map using local image cache??
    var useCache: Bool = true { //use tile overlay cache (
        didSet {
            if self.tileServerOverlay is CachedTileOverlay {
                print("GPXMapView:: setting useCache \(self.useCache)")
                (self.tileServerOverlay as! CachedTileOverlay).useCache = self.useCache
            }
        }
    }
    
    /// Arrow image to display heading (orientation of the device)
    /// initialized on MapViewDelegate
    var headingImageView: UIImageView?
    
    
    /// Selected tile server.
    /// - SeeAlso: GPXTileServer
    var tileServer: GPXTileServer = .apple {
        willSet {
            // Info about how to use other tile servers:
            //http://www.glimsoft.com/01/31/how-to-use-openstreetmap-on-ios-7-in-7-lines-of-code/2
            
            print("Setting map tiles overlay to: \(newValue.name)" )
            
            // remove current overlay
            if self.tileServer != .apple {
                //remove current overlay
                self.remove(self.tileServerOverlay)
            }
            //add new overlay to map
            if newValue != .apple {
                self.tileServerOverlay = CachedTileOverlay(urlTemplate: newValue.templateUrl)
                (self.tileServerOverlay as! CachedTileOverlay).useCache = self.useCache
                tileServerOverlay.canReplaceMapContent = true
                self.insert(tileServerOverlay, at: 0, level: .aboveLabels)
            }
        }
    }
    
    /// Overlay that holds map tiles
    var tileServerOverlay: MKTileOverlay = MKTileOverlay()
    
    
    var saveMapViewZoom:Bool = true
    fileprivate var mapViewZoom:MKCoordinateRegion? {
        get {
            guard let codeData = UserDefaults.standard.data(forKey: "mapViewZoomKey") else {
                return nil
            }
            guard let status = try! NSKeyedUnarchiver.unarchiveObject(with: codeData) as? MapViewZoomStatusModel else {
                return nil
            }
            return MKCoordinateRegion.init(center: CLLocationCoordinate2D(latitude: status.latitude, longitude: status.longitude), span: MKCoordinateSpan.init(latitudeDelta: status.longitudeDelta, longitudeDelta: status.longitudeDelta))
        }
        
        set {
            guard let newValue = newValue else { return }
            let status = MapViewZoomStatusModel(coordinate: newValue.center, coordinateSpan: newValue.span)
            let encodedData = NSKeyedArchiver.archivedData(withRootObject: status)
            UserDefaults.standard.set(encodedData, forKey: "mapViewZoomKey")
        }
    }
    
    ///
    /// Initializes the map with an empty currentSegmentOverlay.
    ///
    required init() {
        var tmpCoords: [CLLocationCoordinate2D] = [] //init with empty
        self.currentSegmentOverlay = MKPolyline(coordinates: &tmpCoords, count: 0)
        self.compassRect = CGRect.init(x: 0, y: 0, width: 36, height: 36)
        super.init(frame: compassRect)
        
//        let center = CLLocationCoordinate2D(latitude: 8.90, longitude: -79.50)
//        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
//        let region = MKCoordinateRegion(center: center, span: span)
//        mapViewZoom = region
//        
//        if let zoom = mapViewZoom {
//            print("▬▬▬▬▬▬▬▬▬▬ஜ۩۞۩ஜ▬▬▬▬▬▬▬▬▬▬▬▬▬▬存储成功")
//        } else {
//            print("▬▬▬▬▬▬▬▬▬▬ஜ۩۞۩ஜ▬▬▬▬▬▬▬▬▬▬▬▬▬▬存储失败")
//        }
        
    }
    
    deinit {
        // let center = locationManager.location?.coordinate ?? CLLocationCoordinate2D(latitude: 8.90, longitude: -79.50)
        // let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        // let region = MKCoordinateRegion(center: center, span: span)
        // map.setRegion(region, animated: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///
    /// Override default implementation to set the compass that appears in the map in a better position.
    ///
    override func layoutSubviews() {
        super.layoutSubviews()
        // set compass position by setting its frame
        if let compassView = self.subviews.filter({ $0.isKind(of:NSClassFromString("MKCompassView")!) }).first {
            if compassRect.origin.x != 0 {
                compassView.frame = compassRect
            }
        }
    }
    
    ///
    /// Adds a waypoint annotation in the point passed as arguments
    ///
    /// For example, this function can be used to add a waypoint after long press on the map view
    ///
    /// - Parameters:
    ///     - point: The location in which the waypoint has to be added.
    ///
    func addWaypointAtViewPoint(_ point: CGPoint) {
        let coords: CLLocationCoordinate2D = self.convert(point, toCoordinateFrom: self)
        let waypoint = GPXWaypoint(coordinate: coords)
        self.addWaypoint(waypoint)
    }
    
    ///
    /// Adds a waypoint to the map.
    ///
    /// - Parameters: The waypoint to add to the map.
    ///
    func addWaypoint(_ waypoint: GPXWaypoint) {
        self.waypoints.append(waypoint)
        self.addAnnotation(waypoint)
        self.extent.extendAreaToIncludeLocation(waypoint.coordinate)
    }
    
    ///
    /// Removes a Waypoint from the map
    ///
    /// - Parameters: The waypoint to remove from the map.
    ///
    func removeWaypoint(_ waypoint: GPXWaypoint) {
        let index = waypoints.index(of: waypoint)
        if index == nil {
            print("Waypoint not found")
            return
        }
        self.removeAnnotation(waypoint)
        waypoints.remove(at: index!)
        //TODO: update map extent?
        
    }
    
    ///
    /// Updates the heading arrow based on the heading information
    ///
    func updateHeading(_ heading: CLHeading) {
        headingImageView?.isHidden = false
        let rotation = CGFloat(heading.trueHeading/180 * Double.pi)
        headingImageView?.transform = CGAffineTransform(rotationAngle: rotation)
    }
    
    
    ///
    /// Adds a new point to current segment.
    /// - Parameters:
    ///    - location: Typically a location provided by CLLocation
    ///
    func addPointToCurrentTrackSegmentAtLocation(_ location: CLLocation) {
        let pt = GPXTrackPoint(location: location)
        self.currentSegment.add(trackpoint: pt)
        //redrawCurrent track segment overlay
        //First remove last overlay, then re-add the overlay updated with the new point
        self.remove(currentSegmentOverlay)
        currentSegmentOverlay = currentSegment.overlay
        self.add(currentSegmentOverlay)
        self.extent.extendAreaToIncludeLocation(location.coordinate)
        
        //add the distance to previous tracked point
        if self.currentSegment.trackpoints.count >= 2 { //at elast there are two points in the segment
            let prevPt = self.currentSegment.trackpoints[self.currentSegment.trackpoints.count-2] //get previous point
            guard let latitude = prevPt.latitude, let longitude = prevPt.longitude else { return }
            let prevPtLoc = CLLocation(latitude: latitude, longitude: longitude)
            //now get the distance
            let distance = prevPtLoc.distance(from: location)
            self.currentTrackDistance += distance
            self.totalTrackedDistance += distance
            self.currentSegmentDistance += distance
        }
    }
    
    ///
    /// If current segmet has points, it appends currentSegment to trackSegments and
    /// initializes currentSegment to a new one.
    ///
    func startNewTrackSegment() {
        if self.currentSegment.trackpoints.count > 0 {
            self.trackSegments.append(self.currentSegment)
            self.currentSegment = GPXTrackSegment()
            self.currentSegmentOverlay = MKPolyline()
            self.currentSegmentDistance = 0.00
        }
    }
    
    ///
    /// Finishes current segmet.
    ///
    func finishCurrentSegment() {
        self.startNewTrackSegment() //basically, we need to append the segment to the list of segments
    }
    
    ///
    /// Clears map.
    ///
    func clearMap() {
        self.trackSegments = []
        self.tracks = []
        self.currentSegment = GPXTrackSegment()
        self.waypoints = []
        self.removeOverlays(self.overlays)
        self.removeAnnotations(self.annotations)
        self.extent = GPXExtentCoordinates()
        
        self.totalTrackedDistance = 0.00
        self.currentTrackDistance = 0.00
        self.currentSegmentDistance = 0.00
        
        //add tile server overlay
        //by removing all overlays, tile server overlay is also removed. We need to add it back
        if tileServer != .apple {
            self.add(tileServerOverlay, level: .aboveLabels)
        }
    }
    
    ///
    ///
    /// Converts current map into a GPX String
    ///
    ///
    func exportToGPXString() -> String {
        print("Exporting map data into GPX String")
        //Create the gpx structure
        let gpx = GPXRoot(creator: kGPXCreatorString)
        gpx.add(waypoints: self.waypoints)
        let track = GPXTrack()
        track.add(trackSegments: self.trackSegments)
        //add current segment if not empty
        if self.currentSegment.trackpoints.count > 0 {
            track.add(trackSegment: self.currentSegment)
        }
        //add existing tracks
        gpx.add(tracks: self.tracks)
        //add current track
        gpx.add(track: track)
        return gpx.gpx()
    }
   
    ///
    /// Sets the map region to display all the GPX data in the map (segments and waypoints).
    ///
    func regionToGPXExtent() {
        self.setRegion(extent.region, animated: true)
    }
    
    /*
    func importFromGPXString(gpxString: String) {
        // TODO
    }
    */
    
    /// Imports GPX contents into the map.
    ///
    /// - Parameters:
    ///     - gpx: The result of loading a gpx file with iOS-GPX-Framework.
    ///
    func importFromGPXRoot(_ gpx: GPXRoot) {
        //clear current map
        self.clearMap()
        
        //add waypoints
        self.waypoints = gpx.waypoints
        
        for pt in self.waypoints {
            self.addWaypoint(pt)
        }
        //add track segments
        self.tracks = gpx.tracks
        
        for oneTrack in self.tracks {
            totalTrackedDistance += oneTrack.length
            for segment in oneTrack.tracksegments {
                let overlay = segment.overlay
                self.add(overlay)
                let segmentTrackpoints = segment.trackpoints
                //add point to map extent
                for waypoint in segmentTrackpoints {
                    self.extent.extendAreaToIncludeLocation(waypoint.coordinate)
                }
            }
        }
    }
}

struct MapViewZoomStatusModel : Codable {
//    let center = CLLocationCoordinate2D(latitude: 8.90, longitude: -79.50)
//    let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
//    let region = MKCoordinateRegion(center: center, span: span)
//    mapViewZoom = region
    var latitude:Double
    var longitude:Double
    var latitudeDelta:Double
    var longitudeDelta:Double
    
    init(coordinate:CLLocationCoordinate2D, coordinateSpan:MKCoordinateSpan) {
        latitude = coordinate.latitude
        longitude = coordinate.longitude
        latitudeDelta = coordinateSpan.longitudeDelta
        longitudeDelta = coordinateSpan.longitudeDelta
    }
}

