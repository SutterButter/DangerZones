//

//  ViewController.swift
//  TheDangerZone
//
//  Created by Noah Sutter on 6/14/17.
//  Copyright © 2017 Noah Sutter. All rights reserved.
//

import UIKit
import MapKit
import AVFoundation


protocol HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark)
}

class ViewController: UIViewController {
    
    //Declaring outlets for the map and text directions
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var instructionsText: UINavigationItem!
    
    var locationSearchTable:LocationSearchTable!
    
    // Declaring the location manager
    var locationManager = CLLocationManager()
    
    // Setting up search autocomplete
    var resultSearchController:UISearchController? = nil
    

    var selectedPin:MKPlacemark? = nil
    
    
    // Declaring routes
    var route :MKRoute = MKRoute()
    var alternate1 :MKRoute = MKRoute()
    var alternate2 :MKRoute = MKRoute()
    var safestRoute :MKRoute = MKRoute()
    
    // Declaring the current location
    var center = CLLocationCoordinate2D()
    
    // Intializing the current direction step index
    var curr = 1
    
    // Initializing the variable that tells whether we are far enough from the last danger zone to announce the next
    var madefar = false
    
    // Declaring the array that will hold all the DangerZones on the Route
    var zonesOnRoute:[CLLocationCoordinate2D] = []
    
    // Declaring the array that tells if a Danger Zone has been announced already
    var zonesOnRouteClosing:[Bool] = []
    
    // Declaring the speech synthesizer
    let synthesizer = AVSpeechSynthesizer()
    
    // Initializing the location of the last DangerZone
    var lastDangerZone = CLLocation(latitude: 0,longitude: 0)
    
    // Initializing an array with all the potential DangerZones
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
    
    
    
    
    
    
    
    
    
    
    // When the view is loaded:
    override func viewDidLoad() {
        //Speaking the initial "proceed to the route"
        super.viewDidLoad()
        
        
        //Setting up the location manager
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.startUpdatingLocation()
        
        
        // Setting up search controller and table
        locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        // Displaying the search bar
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for destination"
        navigationItem.titleView = resultSearchController?.searchBar
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
        
        
        // Setting the Map Delegate
        mapView.delegate = self
        
        
        // Setting location search Table's map view to be the same
        locationSearchTable.mapView = self.mapView
        
        locationSearchTable.handleMapSearchDelegate = self
        
        // Show the current location
        self.mapView.showsUserLocation = true
        
        //Zoom to user location
        let noLocation = locationManager.location!.coordinate
        let viewRegion = MKCoordinateRegionMakeWithDistance(noLocation, 1000, 1000)
        self.mapView.setRegion(viewRegion, animated: false)
    }
    
    
    
    
    
    func getDirections(){
        if let selectedPin = selectedPin {
            
            //Removing annotations and clearing arrays
            let annotations = self.mapView.annotations
            self.mapView.removeAnnotations(annotations)
            self.zonesOnRoute = []
            self.zonesOnRouteClosing = []
            
            self.navigationItem.titleView = nil
            
            //self.view.bringSubviewToFront(instructionsText)
            let mapItem = MKMapItem(placemark: selectedPin)
            
            
            let utterance = AVSpeechUtterance(string: "Proceed to the route")
            utterance.rate = 0.5
            self.synthesizer.speak(utterance)
            
            
            
            // Adding the source and destination locations
            let sourceLocation = locationManager.location!.coordinate
            //latitude: 40.8761779870838, longitude: -81.4120410013506
            
            
            let destinationLocation = selectedPin.coordinate
            
            // Placemarks
            let sourcePlacemark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
            let destinationPlacemark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
            
            // Map Items
            let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
            let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
            

            let destinationAnnotation = MKPointAnnotation()
            destinationAnnotation.title = "Destination"
            if let location = destinationPlacemark.location {
                destinationAnnotation.coordinate = location.coordinate
            }
            
            // Adding the annotations to the map
            self.mapView.showAnnotations([destinationAnnotation], animated: true)
            
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
                
                // Checking for error
                guard let response = response else {
                    if let error = error {
                        print("Error: \(error)")
                    }
                    return
                }
                
                
                let routes = response.routes
                var min = Double()
                var firstTest = true
                var mapOfRoutes = Dictionary<Double, MKRoute>()
                for mapRoute in routes {
                    let score = self.getDangerScore(route: mapRoute)
                    if firstTest {
                        min = score
                        firstTest = false
                    }
                    if score < min {
                        min = score
                    }
                    if mapOfRoutes[score] == nil {
                        mapOfRoutes[score] = mapRoute
                    }
                }
                self.safestRoute = mapOfRoutes[min]!
 
                // Adding the route to the map
                self.mapView.add((self.safestRoute.polyline), level: MKOverlayLevel.aboveRoads)
                
                // Getting the boundingMapObject and creating a region from it
                let rect = self.safestRoute.polyline.boundingMapRect
                var region = MKCoordinateRegionForMapRect(rect)
                
                // Enlarging the region
                region.span.latitudeDelta *= 1.2
                region.span.longitudeDelta *= 1.2
                
                // Setting the region (this will set what region the app displays on the map)
                self.mapView.setRegion(region, animated: true)
                
                
                
                // Adding danger zones to the map that are along the route
                self.getDangerZones(route: self.safestRoute)
                
                // Updating current driving instruction
                self.instructionsText.title = self.safestRoute.steps[0].instructions
                
                
            }

        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    
    
    
    // Rendering the overlays
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        //Rendering the safest route
        if overlay as? MKPolyline  == self.safestRoute.polyline {
            let lineRenderer = MKPolylineRenderer(overlay: overlay)
            lineRenderer.strokeColor = UIColor(hue: 0.5694, saturation: 0.67, brightness: 0.97, alpha: 1.0) /* #51b2f7 */
            lineRenderer.lineWidth = 4.0
            return lineRenderer
        }
            
            //Rendering the Danger Zone circles
        else {
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            //circleRenderer.strokeColor = UIColor(red:0.93, green:0.65, blue:0.65, alpha:0.3)
            circleRenderer.fillColor = UIColor(red:0.93, green:0.65, blue:0.65, alpha:0.7)
            return circleRenderer;
        }
    }
    
    
    
    
    
    
    
    
    // Calculates what danger zones are on the route to be followed
    func getDangerZones(route:MKRoute) {
        
        // Getting the coordinates in the polyline
        let poly = route.polyline
        let coordsPointer = UnsafeMutablePointer<CLLocationCoordinate2D>.allocate(capacity: poly.pointCount)
        poly.getCoordinates(coordsPointer, range: NSMakeRange(0, poly.pointCount))
        var coords: [CLLocationCoordinate2D] = []
        for i in 0..<poly.pointCount {
            coords.append(coordsPointer[i])
        }
        coordsPointer.deallocate(capacity: poly.pointCount)
        
        // Calculating which zones are on the route
        for zone in dangers {
            let pos = CLLocationCoordinate2D(latitude: zone[0],longitude: zone[1])
            var prevCoord = CLLocationCoordinate2D()
            var first = true
            
            // Finding the conversion factor between the mapView's units and meters
            let mpTopLeft = mapView.visibleMapRect.origin;
            let mpTopRight = MKMapPointMake(
                mapView.visibleMapRect.origin.x + mapView.visibleMapRect.size.width,
                mapView.visibleMapRect.origin.y);
            let width = mapView.visibleMapRect.size.width
            let hDist = MKMetersBetweenMapPoints(mpTopLeft, mpTopRight)
            let converter = hDist/width
            
            // Checking if each zone is on any of the route sections
            for point in coords {
                let curRect = MKMapRect(origin: MKMapPointForCoordinate(pos), size: MKMapSize(width: (100 / converter),height: (100 / converter)))
                if !first {
                    let points = [prevCoord, point]
                    let testPoly = MKPolyline(coordinates: points, count: points.count)
                    if testPoly.intersects(curRect){
                        if !zonesOnRoute.contains(where: { $0.latitude == pos.latitude && $0.longitude == pos.longitude }){
                            self.mapView.add(MKCircle(center: pos, radius: 100))
                            zonesOnRoute.append(pos)
                            zonesOnRouteClosing.append(false)
                        }
                    }
                } else {
                    first = false
                }
                prevCoord = point
            }
        }
    }
    
    
    
    
    
    
    // Calculates how dangerous a route is
    func getDangerScore(route:MKRoute) -> Double {
        
        // Getting the coordinates in the polyline
        let poly = route.polyline
        let coordsPointer = UnsafeMutablePointer<CLLocationCoordinate2D>.allocate(capacity: poly.pointCount)
        poly.getCoordinates(coordsPointer, range: NSMakeRange(0, poly.pointCount))
        var coords: [CLLocationCoordinate2D] = []
        for i in 0..<poly.pointCount {
            coords.append(coordsPointer[i])
        }
        coordsPointer.deallocate(capacity: poly.pointCount)
        
        // Initializing the score
        var score = 0.0
        
        // Calculating which zones are on the route and getting their scores
        for zone in dangers {
            let pos = CLLocationCoordinate2D(latitude: zone[0],longitude: zone[1])
            var prevCoord = CLLocationCoordinate2D()
            var first = true
            
            // Finding the conversion factor between the mapView's units and meters
            let mpTopLeft = mapView.visibleMapRect.origin;
            let mpTopRight = MKMapPointMake(
                mapView.visibleMapRect.origin.x + mapView.visibleMapRect.size.width,
                mapView.visibleMapRect.origin.y);
            let width = mapView.visibleMapRect.size.width
            let hDist = MKMetersBetweenMapPoints(mpTopLeft, mpTopRight)
            let converter = hDist/width
            
            // Checking if each zone is on any of the route sections
            for point in coords {
                let curRect = MKMapRect(origin: MKMapPointForCoordinate(pos), size: MKMapSize(width: (100 / converter),height: (100 / converter)))
                if !first {
                    let points = [prevCoord, point]
                    let testPoly = MKPolyline(coordinates: points, count: points.count)
                    if testPoly.intersects(curRect){
                        // Updating this route's score
                        score+=zone[2]
                    }
                } else {
                    first = false
                }
                prevCoord = point
            }
        }
        return score
    }
}



// Location Manager Functions
extension ViewController: CLLocationManagerDelegate {
    
    
    
    
    
    // Handling location manager falling
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        NSLog("locationManager:didFailWithError")
    }
    
    
    
    
    
    
    // Handling when the location is updated
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // Updating the current location
        let location = locations.last
        self.center = CLLocationCoordinate2D(latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!)
        
        // Updating current instruction
        if self.safestRoute.steps.count > self.curr {
            
            // Getting the coordinates in the polyline
            let poly = self.safestRoute.steps[self.curr].polyline
            var coordsPointer = UnsafeMutablePointer<CLLocationCoordinate2D>.allocate(capacity: poly.pointCount)
            poly.getCoordinates(coordsPointer, range: NSMakeRange(0, poly.pointCount))
            var coords: [CLLocationCoordinate2D] = []
            for i in 0..<poly.pointCount {
                coords.append(coordsPointer[i])
            }
            coordsPointer.deallocate(capacity: poly.pointCount)
            
            // Getting the end point of the step
            let point = coords[0]
            let location2 = CLLocation(latitude: point.latitude, longitude: point.longitude)
            
            // If the current location is less than 50 meters from the end of the route step, announce the instruction
            if  Int((location?.distance(from: location2))!) < 50 {
                if (madefar) {
                    let utterance = AVSpeechUtterance(string: self.instructionsText.title!)
                    utterance.rate = 0.5
                    self.synthesizer.speak(utterance)
                    self.madefar = false
                }
            }
                // If the current location is now more than 50 meters away from the last step
            else if (!madefar) {
                
                // Converting the distance from meters to feet
                var distance=Int(self.safestRoute.steps[self.curr].distance * 3.28)
                
                // Declaring the utterance for the next step
                var utterance = AVSpeechUtterance()
                
                // Setting the utterance based on how far the next step is (using miles, fractinos of miles, or feet)
                // and rounding that distance
                if distance > 5280 {
                    distance = distance / 528
                    let newDistance = Double(distance)/10.0
                    utterance = AVSpeechUtterance(string: "In " + String(newDistance) + " miles, " + self.safestRoute.steps[self.curr].instructions )
                } else if distance > 528 {
                    distance = (distance / 528)
                    utterance = AVSpeechUtterance(string: "In point " + String(distance) + " miles, " + self.safestRoute.steps[self.curr].instructions)
                    
                } else if distance > 100 {
                    distance = (distance / 100) * 100
                    utterance = AVSpeechUtterance(string:  "In " + String(distance) + " feet, " + self.safestRoute.steps[self.curr].instructions)
                } else {
                    utterance = AVSpeechUtterance(string: "In " + String(distance) + " feet, " + self.safestRoute.steps[self.curr].instructions)
                }
                
                // Speaking the next step
                utterance.rate = 0.5
                self.synthesizer.speak(utterance)
                self.instructionsText.title = self.safestRoute.steps[self.curr].instructions
                
                // Updating to the next step
                self.madefar = true
                curr+=1
            }
        }
        
        // Announcing Danger Zones
        for i in 0..<(zonesOnRoute.count) {
            // Getting the DangerZone's location
            let zone = zonesOnRoute[i]
            let zonePos = CLLocation(latitude: zone.latitude, longitude: zone.longitude)
            
            // If any of the zones are withing 200 meters and have not been announced already, start announcing the danger zone
            if Int((location?.distance(from: zonePos))!) < 200  && !zonesOnRouteClosing[i]{
                
                // Making sure another danger zone has not been recently announced
                if Int((zonePos.distance(from: self.lastDangerZone))) > 200 {
                    self.lastDangerZone = zonePos
                    zonesOnRouteClosing[i] = true
                    let utterance = AVSpeechUtterance(string: "Danger Zone in 500 feet")
                    utterance.rate = 0.5
                    self.synthesizer.speak(utterance)
                }
            }
        }
    }
    
}



extension ViewController: HandleMapSearch {
    func dropPinZoomIn(placemark:MKPlacemark){
        // cache the pin
        selectedPin = placemark
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
            let state = placemark.administrativeArea {
            annotation.subtitle = (city + ", " + state)
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegionMake(placemark.coordinate, span)
        mapView.setRegion(region, animated: true)
    }
}


extension ViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        if annotation is MKUserLocation {
            //return nil so map view draws "blue dot" for standard user location
            return nil
        }
        let overlays = self.mapView.overlays
        self.mapView.removeOverlays(overlays)
        
        let pinView = MKPinAnnotationView()
        pinView.pinTintColor = UIColor.red
        pinView.canShowCallout = true
        let smallSquare = CGSize(width: 30, height: 30)
        let button = UIButton(frame: CGRect(origin: CGPoint(), size: smallSquare))
        button.setBackgroundImage(UIImage(named: "car"), for: .normal)
        button.addTarget(self, action: Selector("getDirections"), for: .touchUpInside)
        pinView.leftCalloutAccessoryView = button
        return pinView
    }
}
