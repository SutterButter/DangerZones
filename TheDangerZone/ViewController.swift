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
    var center = CLLocationCoordinate2D()
    
    let dangers = [[40.847997130434784,-81.4343505652174,25.0],
                   [40.85489372222222,-81.43209894444445,21.0],
                   [40.86267389473685,-81.43219721052633,20.0],
                   [40.84882283333332,-81.44345546666668,79.0],
                   [40.87304668750001,-81.44145381249999,18.0],
                   [40.85943568707482,-81.42262564625847,175.0],
                   [40.86958913333334,-81.43089846666666,42.0],
                   [40.871188617021296,-81.42258238297872,54.0],
        [40.87893839361701,-81.44114830851066,115.0],
        [40.897876899999986,-81.42938604999999,27.0],
        [40.83147795890412,-81.34711183561642,93.0],
        [40.85949140000001,-81.42788628,65.0],
        [40.84321116216216,-81.43500864864866,51.0],
        [40.85879527419356,-81.4325650887097,143.0],
        [40.88003176536316,-81.43335428491619,211.0],
        [40.85639087499999,-81.43257392500001,44.0],
        [40.83429572727273,-81.46266140909091,29.0],
        [40.82908361538462,-81.4086253076923,16.0],
        [40.8332296,-81.4336903,12.0],
        [40.85047378947369,-81.44560389473685,22.0],
        [40.88855809090908,-81.42350727272726,24.0],
        [40.87816292857143,-81.46037164285715,18.0],
        [40.88163906451612,-81.42385070967741,37.0],
        [40.879490437499996,-81.438524125,21.0],
        [40.85655294999999,-81.4358876,23.0],
        [40.85512685915492,-81.42303947887324,90.0],
        [40.875853541666665,-81.40224466666668,29.0],
        [40.890571740740704,-81.4058639814815,64.0],
        [40.890094090909095,-81.39092481818183,13.0],
        [40.89088364285715,-81.41961814285716,17.0],
        [40.898366125,-81.40623231249998,22.0],
        [40.861003066666655,-81.39562260000001,15.0],
        [40.85038949999999,-81.4412845,23.0],
        [40.874780522727285,-81.36377677272729,51.0],
        [40.83509152380953,-81.33636680952381,25.0],
        [40.830554000000014,-81.3546857037037,31.0],
        [40.83291038461539,-81.42438096153845,36.0],
        [40.87877626315788,-81.47965757894738,24.0],
        [40.87441533333334,-81.43196475,14.0],
        [40.83061868421053,-81.35292157894735,24.0],
        [40.86060381818183,-81.48511296969697,38.0],
        [40.83642028571428,-81.42396607142858,19.0],
        [40.88319645454545,-81.40337599999998,13.0],
        [40.83074830434783,-81.35894030434781,36.0],
        [40.83414678571429,-81.33992278571428,16.0],
        [40.82573952,-81.39960300000001,30.0],
        [40.904672272727275,-81.40580418181817,15.0],
            [40.8270377368421,-81.40352352631581,26.0],
            [40.8978939,-81.42138829999999,12.0],
            [40.87149779999999,-81.40018909999999,13.0],
            [40.873867733333334,-81.3343162,16.0],
            [40.899169199999996,-81.42111730000002,14.0],
            [40.855436363636365,-81.46115454545455,12.0],
            [40.857797,-81.396304,14.0],
            [40.85876399999998,-81.39514400000002,26.0],
            [40.82785476923077,-81.48823269230769,16.0],
            [40.90195863636363,-81.40585227272727,16.0],
            [40.8593385,-81.4263969375,20.0],
            [40.83102575,-81.36571558333333,15.0],
            [40.83290341666667,-81.41921583333334,16.0],
            [40.89059972727272,-81.40692181818181,12.0],
            [40.87833214285714,-81.46638657142854,16.0],
            [40.85911787500001,-81.430790125,10.0],
            [40.855286899999996,-81.4249134,14.0],
            [40.8915789,-81.4198245,11.0]]

    
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
            var region = MKCoordinateRegionForMapRect(rect)
            
            // Enlarging the region
            region.span.latitudeDelta *= 1.2
            region.span.longitudeDelta *= 1.2
            
            // Setting the region
            self.mapView.setRegion(region, animated: true)
            
            self.mapView.showsUserLocation = true
            
            self.getDangerZones(route: self.route)
            
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
        self.center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        //let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        //self.mapView.setRegion(region, animated: true)
    }
    
    func getDangerZones(route:MKRoute) {
        //getting the coordinates in the polyline
        let poly = route.polyline
        var coords: [CLLocationCoordinate2D] = []
        coords.reserveCapacity(poly.pointCount)
        route.polyline.getCoordinates(&coords, range: NSMakeRange(0, poly.pointCount))
        
        let curRect = MKMapRect(origin: MKMapPointForCoordinate(self.center), size: MKMapSize(width: 50,height: 50))
        var count = 0
        for pos in coords {
            if poly.intersects(curRect) {
                count+=1
                print(count)
            }
        }
    }
    
    
    func Distance(x:Double, y:Double, x1:Double, y1:Double, x2:Double, y2:Double) -> Double {
    
    let A = x - x1
    let B = y - y1
    let C = x2 - x1
    let D = y2 - y1
    
    let dot = A * C + B * D
    let len_sq = C * C + D * D
    var param = -1.0
    if (len_sq != 0) { //in case of 0 length line
        param = dot / len_sq
    }
    var xx = 0.0, yy = 0.0
    
    if (param < 0) {
    xx = x1
    yy = y1
    }
    else if (param > 1) {
    xx = x2
    yy = y2
    }
    else {
    xx = x1 + param * C
    yy = y1 + param * D
    }
    
    let dx = x - xx
    let dy = y - yy
    return (dx * dx + dy * dy).squareRoot()
    }

}

