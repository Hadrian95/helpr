//
//  FavoriteLocationsViewController.swift
//  helpr
//
//  Created by adrian.parcioaga and walter.alvarez on 2018-11-19.
//  Copyright © 2018 helpr. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class FavoriteLocationsViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mvMap: MKMapView!
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //prompt user for location permissions and focus map
        if (CLLocationManager.locationServicesEnabled())
        {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    //MARK: Methods
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last{
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            self.mvMap.setRegion(region, animated: true)
        }
    }
}
