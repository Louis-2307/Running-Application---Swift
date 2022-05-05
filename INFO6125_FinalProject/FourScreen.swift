//
//  FourScreen.swift
//  INFO6125_FinalProject
//
//  Created by Anh Dinh Le on 2022-04-10.
//

// ref
// https://stackoverflow.com/questions/25449469/show-current-location-and-update-location-in-mkmapview-in-swift
// https://stackoverflow.com/questions/60553583/how-do-i-track-in-the-background-in-ios-a-user-walking-and-calculate-the-distanc
// https://stackoverflow.com/questions/54929036/draw-polyline-depend-on-user-location-swift
// https://rshankar.com/how-to-add-mapview-annotation-and-draw-polyline-in-swift/
// https://stackoverflow.com/questions/28952747/calculate-total-traveled-distance-ios-swift

import UIKit
import MapKit
import CoreLocation

class FourScreen: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var workoutNameEdit: UITextField!
    @IBOutlet weak var stopActivityButton: UIButton!
    
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var Title: String?
    var Distance: String?
    var Duration: String?
    var userLatitude = 25.54
    var userLongitude = -103.41
    var startLocation: CLLocation!
    var lastLocation: CLLocation!
    var traveledDistance: Double = 0
    var startDate: Date!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stopActivityButton.isEnabled = false
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.delegate = self
//        minimize power consumption
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.distanceFilter = 1
        setupMap()
    }
    
    // screen is locked in portrait
    override open var shouldAutorotate: Bool {
       return false
    }

    // Specify the orientation.
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
       return .portrait
    }
    
    private func setupMap() {
        // set delegate
        mapView.delegate = self
        
        // enable showing user location on map
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        
        // 43.0130,-81.1994
        let location = CLLocation(latitude: userLatitude, longitude: userLongitude)
        
        let radiusInMeters: CLLocationDistance = 2000
        
        let region = MKCoordinateRegion(center: location.coordinate,
                                        latitudinalMeters: radiusInMeters,
                                        longitudinalMeters: radiusInMeters)
        
        mapView.setRegion(region, animated: true)
    }
    
    @IBAction func textfieldID(_ sender: UITextField) {
         
         if workoutNameEdit.hasText == false
        {
            stopActivityButton.isEnabled = false
        }
        else if workoutNameEdit.hasText == true
        {
            stopActivityButton.isEnabled = true
        }
    }
    
    @IBAction func onNameTyped(_ sender: UITextField) {
        Title = workoutNameEdit.text!
        //print(Title)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        defer { currentLocation = locations.last }

            if currentLocation == nil {
                // Zoom to user location
                if let userLocation = locations.last {
                    let viewRegion = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
                    mapView.setRegion(viewRegion, animated: false)

                }
            }
        
        if startDate == nil {
            startDate = Date()
        } else {
            print("elapsedTime:", String(format: "%.0fs", Date().timeIntervalSince(startDate)))
            durationLabel.text = String(format: "%.0fs", Date().timeIntervalSince(startDate))
            Duration = durationLabel.text
        }
        
        if startLocation == nil {
            startLocation = locations.first
        } else if let location = locations.last {
            traveledDistance += lastLocation.distance(from: location)
            distanceLabel.text = String(format: "%.0fm", traveledDistance)
            print("Traveled Distance:",  traveledDistance)
            Distance = distanceLabel.text
        }
        lastLocation = locations.last
        
//        from Class Demo
//        print("Got location")
//
//        if let location = locations.last {
//            let latitude = location.coordinate.latitude
//            let longitude = location.coordinate.longitude
//            print ("Latlng \(latitude), \(longitude)")
//            userLatitude = latitude
//            userLongitude = longitude
//        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        if (error as? CLError)?.code == .denied {
                    manager.stopUpdatingLocation()
                    manager.stopMonitoringSignificantLocationChanges()
                }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "myIdentifier"
        var view: MKMarkerAnnotationView
        
        // check to see if we have a view we can reuse
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView {
            // get updated annotation
            dequeuedView.annotation = annotation
            // use our reusable view
            view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            view.canShowCallout = true
            
            // set the position of the callout
            view.calloutOffset = CGPoint(x: 0, y: 10)
            
            // add a button to right side of Callout
            let button = UIButton(type: .detailDisclosure)
            button.tag = 100
            view.rightCalloutAccessoryView = button
            
            // add an image to left side of callout
            let image = UIImage(systemName: "graduationcap.circle.fill")
            view.leftCalloutAccessoryView = UIImageView(image: image)
            
            // change colour of pin/marker
            view.markerTintColor = UIColor.purple
            
            // change colour of accesories
            view.tintColor = UIColor.systemRed
            
            if let myAnnotation = annotation as? MyAnnotation {
                view.glyphText = myAnnotation.glyphText
            }
        }
        
        return view
    }
    
    @IBAction func MoveButton(_ sender: UIButton) {
        locationManager.stopMonitoringSignificantLocationChanges()
        locationManager.stopUpdatingLocation()
        self.performSegue(withIdentifier: "goToNextPage", sender: self)
    }
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "goToNextPage"
            {
            let destination = segue.destination as! SecondScreen
                destination.Title = Title.self
                destination.Duration = Duration.self
                destination.Distance = Distance.self
            }
        }

}

class MyAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var glyphText: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String, glyphText: String? = nil) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle

        super.init()
    }
}
