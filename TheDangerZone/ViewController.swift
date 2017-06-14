//
//  ViewController.swift
//  TheDangerZone
//
//  Created by Noah Sutter on 6/14/17.
//  Copyright © 2017 Noah Sutter. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var instructionsText: UINavigationItem!
    
    
    
    var manager = CLLocationManager()
    var route :MKRoute = MKRoute()
    var alternate1 :MKRoute = MKRoute()
    var alternate2 :MKRoute = MKRoute()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Setting up the location manager
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        
        // Setting the Map Delegate
        mapView.delegate = self
        
        // Adding the source and destination locations
        let sourceLocation = CLLocationCoordinate2D(latitude: 40.877243, longitude: -81.410538)
        let destinationLocation = CLLocationCoordinate2D(latitude: 40.848874, longitude: -81.433845)
        
        // Placemarks
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
        
        // Map Items
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        // Annotations
        let sourceAnnotation = MKPointAnnotation()
        sourceAnnotation.title = "Start Location"
        
        if let location = sourcePlacemark.location {
            sourceAnnotation.coordinate = location.coordinate
        }
        
        let destinationAnnotation = MKPointAnnotation()
        destinationAnnotation.title = "Destination"
        
        if let location = destinationPlacemark.location {
            destinationAnnotation.coordinate = location.coordinate
        }
        
        // Adding the annotations to the map
        self.mapView.showAnnotations([sourceAnnotation,destinationAnnotation], animated: true )
        
        // Requesting the directions
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile
        directionRequest.requestsAlternateRoutes = true
        let directions = MKDirections(request: directionRequest)
        
        // Displaying the initial directions and instructions
        directions.calculate {
            (response, error) -> Void in
            
            //Checking for error
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                return
            }
            
            // Getting and setting the route
            let routes = response.routes
            self.route = routes[0]
            self.alternate1 = routes[1]
            self.alternate2 = routes[2]
            
            self.mapView.add((self.route.polyline), level: MKOverlayLevel.aboveRoads)
            self.mapView.add((self.alternate1.polyline), level: MKOverlayLevel.aboveRoads)
            self.mapView.add((self.alternate2.polyline), level: MKOverlayLevel.aboveRoads)
            
            // Getting the boundingMapObject and creating a region from it
            let rect = self.route.polyline.boundingMapRect
            var region = MKCoordinateRegionForMapRect(rect);
            
            // Enlarging the region
            region.span.latitudeDelta *= 1.2;
            region.span.longitudeDelta *= 1.2;
            
            // Setting the region
            self.mapView.setRegion(region, animated: true)
            
            self.mapView.showsUserLocation = true
            
            // Updating current instruction
            self.instructionsText.title = self.route.steps[0].instructions
        }
        
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        if overlay as? MKPolyline  == self.route.polyline {
            renderer.strokeColor = UIColor.red
            renderer.lineWidth = 4.0
        } else if overlay as? MKPolyline  == self.alternate1.polyline {
            renderer.strokeColor = UIColor.blue
            renderer.lineWidth = 4.0
        } else if overlay as? MKPolyline  == self.alternate2.polyline {
            renderer.strokeColor = UIColor.green
            renderer.lineWidth = 4.0
            
        }
        return renderer
        
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let location = locations.last as! CLLocation
        
        //let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        //let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        //self.mapView.setRegion(region, animated: true)
    }

}

