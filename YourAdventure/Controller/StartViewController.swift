//
//  StartViewController.swift
//  YourAdventure
//
//  Created by Dominik Leszczyński on 17/04/2021.
//

import UIKit
import MapKit
import CoreLocation

class StartViewController: PolylineViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var trackingButton: UIButton!
    @IBOutlet var topViewController: UIView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    //MARK: - Backend
    
    var adventureBackend = AdventureBackend()
    
    //MARK: - LocationVariables
    
    let locationManager = CLLocationManager()
    var locationArray: [CLLocation] = []
    var locationCoordinateArray: [CLLocationCoordinate2D] = []
    
    //MARK: - DefaultValues
    
    var currentDistance:Int = 0
    var currentDistanceFull:Double = 0.0
    
    var stopWatchTime: Double = 0.0
    var stopWatchTimeRounded: Double = 0.0
    
    var startedTracking = false
    var currentUnits = "\(Constants.distanceUnit)"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        mapView.delegate = self
        
        // Check for Location Services
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.requestAlwaysAuthorization()
            locationManager.requestWhenInUseAuthorization()
        }
        
        //Zoom to user location
        if let userLocation = locationManager.location?.coordinate {
            let viewRegion = MKCoordinateRegion(center: userLocation, latitudinalMeters: 100, longitudinalMeters: 100)
            mapView.setRegion(viewRegion, animated: false)
        }
        
        DispatchQueue.main.async {
            self.locationManager.startUpdatingLocation()
            self.mapView.userTrackingMode = .follow
        }
        
//        Label customization
        infoLabel.adjustsFontSizeToFitWidth = true
        infoLabel.text = Constants.Labels.infoText
        showInfoLabel()
    }
    
    @IBAction func trackingButtonPressed(_ sender: UIButton) {
        
//        Check for Location Auth Status, if denied request it or show No Permissions Alert
        let status = CLLocationManager.authorizationStatus()
        switch status {
                case .authorizedAlways:
                    locationManager.startUpdatingLocation()
                case .authorizedWhenInUse:
                    locationManager.requestAlwaysAuthorization()
                    locationManager.startUpdatingLocation()
                case .restricted, .notDetermined:
                    locationManager.requestAlwaysAuthorization()
                case .denied:
                    self.showNoPermissionsAlert()
                default:
                    self.showNoPermissionsAlert()
        }
        
        if let userLocation = locationManager.location?.coordinate {
            
//            Set mapView to center on user location
            let viewRegion = MKCoordinateRegion(center: userLocation, latitudinalMeters: 100, longitudinalMeters: 100)
                mapView.setRegion(viewRegion, animated: false)
                self.mapView.userTrackingMode = .follow
            
//            If tracking didn't start yet
            if sender.titleLabel?.text == "Start" {
                startedTracking = true
                
                stopWatch()
                
                showInfoLabel()
                
                sender.setTitle("Stop", for: .normal)
//                Creating a start annotation
                let annotation = MKPointAnnotation()
                annotation.title = "Start"
                annotation.coordinate = userLocation
                
//                Get user starting position
                locationCoordinateArray.insert(userLocation, at: 0)
                
//                Remove previous PolyLines and Annotations
                for overlay in mapView.overlays {
                    mapView.removeOverlay(overlay)
                }
                for annotation in mapView.annotations {
                    mapView.removeAnnotation(annotation)
                }
                
                mapView.addAnnotation(annotation)
            } else {
//                If tracking was started already
                
                performSegue(withIdentifier: Constants.resultsParentSegue, sender: self)
                
                startedTracking = false
                
//                Reset Values
                stopWatch()
                currentDistance = 0
                currentDistanceFull = 0.0

                
                showInfoLabel()
                
                sender.setTitle("Start", for: .normal)
                
//                Create a Stop MapAnnotation
                let annotation = MKPointAnnotation()
                annotation.title = "Stop"
                annotation.coordinate = userLocation
                mapView.addAnnotation(annotation)
                
//                Get user last position
                locationCoordinateArray.append(userLocation)
            }
            
        }
    }
    

    private func showNoPermissionsAlert() {
//        Create UIAlert
        let alertController = UIAlertController(title: Constants.PermissionsWarning.title,
                                                message: Constants.PermissionsWarning.message, preferredStyle: .alert)
        
//        Create Open Settings UIAlertAction and an url for it
        let openSettings = UIAlertAction(title: Constants.PermissionsWarning.openSettings, style: .default, handler: {
            (action) -> Void in

            guard let URL = Foundation.URL(string: UIApplication.openSettingsURLString) else { return }
            UIApplication.shared.open(URL, options: [:], completionHandler: nil)
        })
//        Create Cancel UIAlertAction that hides the alert
        let cancelAlert = UIAlertAction(title: Constants.PermissionsWarning.cancel, style: .default, handler: {
            (action) -> Void in
            self.dismiss(animated: true, completion: nil)
        })
        
//        Add previously created Actions and present UIAlerts
        alertController.addAction(openSettings)
        alertController.addAction(cancelAlert)
        
        self.present(alertController, animated: true, completion: nil)
    }

    
}

//MARK: - CLLocationManagerDelegate

extension StartViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if startedTracking {
            for location in locations {
//                If there are more than two locations calculate distance,
//                  between the two last ones.
                if locationArray.count >= 2 {
                    
//                    Get distance between current location and previous one
                    let currentLocation = locationArray[locationArray.count - 1]
                    let previousLocation = locationArray[(locationArray.count - 2)]
                    
//                    Calculate Distance + Round it to an Int
                    currentDistanceFull += previousLocation.distance(from: currentLocation)
                    currentDistance = Int(currentDistanceFull)
                    
                    DispatchQueue.main.async {
                        self.distanceLabel.text = "\(Constants.Labels.distanceText) \(self.currentDistance)\(self.currentUnits)"
                    }
                }
                locationCoordinateArray.append(location.coordinate)
                locationArray.append(location)
            }
//            Create a PolyLine and add it to mapView
            let polyline = MKPolyline(coordinates: locationCoordinateArray, count: locationCoordinateArray.count)
            mapView.addOverlay(polyline)
        } else {
//            Empty locations when tracking is turned off
            locationCoordinateArray = []
        }
    }
}

//MARK: - StopWatch

extension StartViewController {
    func stopWatch() {
        if startedTracking {
//            Create a timer counting every 0.1 seconds
            let timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                
                if self.startedTracking == false {
//                    Reset timer and time values
                    timer.invalidate()
                    self.stopWatchTime = 0.0
                    self.stopWatchTimeRounded = 0.0
                    self.updateTimeLabel()
                } else {
                    self.stopWatchTime += 0.1
                    self.stopWatchTimeRounded = {
                        let stopWatchTimex10 = (self.stopWatchTime * 10)
                        
                        return ((stopWatchTimex10.rounded())/10)
                    }()
                    self.updateTimeLabel()
                }
                
            }
        }
    }
    func updateTimeLabel() {
        DispatchQueue.main.async {
            self.timeLabel.text = "\(self.stopWatchTimeRounded)s"
        }
    }
    func showInfoLabel() {
        if startedTracking {
            self.timeLabel.isHidden = false
            self.distanceLabel.isHidden = false
            self.infoLabel.isHidden = true
        } else {
            self.timeLabel.isHidden = true
            self.distanceLabel.isHidden = true
            self.infoLabel.isHidden = false
        }
    }
}

//MARK: - PrepareForResultsSegue

extension StartViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        Send recorded distance and time to the ResultsParentViewController
//        Then ResultsParentViewController will pass it to ResultsViewController
        if segue.identifier == Constants.resultsParentSegue {
            let destinationVC = segue.destination as! ResultsParentViewController
            
            destinationVC.distanceValue = currentDistance
            destinationVC.timeValue = stopWatchTimeRounded
            destinationVC.coordinates = locationCoordinateArray
        }
    }
}
