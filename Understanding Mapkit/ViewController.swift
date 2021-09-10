//
//  ViewController.swift
//  Understanding Mapkit
//
//  Created by Mac on 14/01/2021.
//

import UIKit
import MapKit
import CoreLocation
import CoreGPX

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    var locationManager: CLLocationManager?
    var currentLocation: CLLocation?
    var updatedingLocations = [CLLocationCoordinate2D]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.startUpdatingLocation()
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        
        // Do any additional setup after loading the view.
    }

    @IBAction func stopTapped(_ sender: Any) {
        locationManager?.stopUpdatingLocation()
        locationManager?.pausesLocationUpdatesAutomatically = true
        let gpxRoot = GPXRoot(creator: "Understanding mapkit")
        var trackpoints = [GPXTrackPoint]()
        let yourElevationValue: Double = 10.724
        for updatedLocation in updatedingLocations {
            let trackPoint = GPXTrackPoint(latitude: updatedLocation.latitude, longitude: updatedLocation.longitude)
            trackPoint.elevation = yourElevationValue
            trackPoint.time = Date()
            trackpoints.append(trackPoint)
        }
        let track = GPXTrack()
        let tracksegment = GPXTrackSegment()
        tracksegment.add(trackpoints: trackpoints)
        track.add(trackSegment: tracksegment)
        gpxRoot.add(track: track)

        print(gpxRoot.gpx())
        
        do {
            let filepath = getDocumentsDirectory().appendingPathComponent("myData")
            
            if !FileManager.default.fileExists(atPath: filepath.path) {
                try! FileManager.default.createDirectory(at: filepath, withIntermediateDirectories: true, attributes: nil)
            }
            
        try gpxRoot.outputToFile(saveAt: filepath, fileName: "test.gpx")
            print(filepath)
        } catch let err {
            print(err.localizedDescription)
        }
        
        
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
}

extension ViewController: CLLocationManagerDelegate, MKMapViewDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let userLocation = locations.first {
          
            
            let center = CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            mapView.region = MKCoordinateRegion(center: center, span: span)
            
            updatedingLocations.append(userLocation.coordinate)
            self.makePolyline(locations: userLocation.coordinate)
        }
        
        
    }
    func makePolyline(locations: CLLocationCoordinate2D) {
        updatedingLocations.append(locations)
        let polyline = MKPolyline(coordinates: &updatedingLocations, count: updatedingLocations.count)
        mapView.addOverlay(polyline)
//        let render = MKPolylineRenderer(polyline: polyline)
//        render.strokeColor = UIColor.blue.withAlphaComponent(0.5)
//        render.lineWidth = 7
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        if let polyline = overlay as? MKPolyline {
                    let testlineRenderer = MKPolylineRenderer(polyline: polyline)
            testlineRenderer.strokeColor = UIColor.blue.withAlphaComponent(0.10)
                    testlineRenderer.lineWidth = 7
                    return testlineRenderer
                }
                fatalError("Something wrong...")
                //return MKOverlayRenderer()

            
    }
    
    
    
}
