//
//  HistoryMapViewController.swift
//  YourAdventure
//
//  Created by Dominik Leszczyński on 04/05/2021.
//

import UIKit
import MapKit
import CoreLocation

class HistoryMapViewController: PolylineViewController {

    @IBOutlet weak var uiNavigation: UINavigationItem!
    @IBOutlet weak var mapView: MKMapView!
    
    let adventureBackend = AdventureBackend()
    
    var selectedAdventure = Adventure()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiNavigation.title = Constants.Labels.historyMapText
        
        mapView.delegate = self
        
//        Create a back button
        let backItem = UIBarButtonItem()
        backItem.title = "Back"
        backItem.style = .plain
        backItem.action = #selector(Progress.cancel)
        uiNavigation.backBarButtonItem = backItem
        
        let adventureCoordinates = adventureBackend.loadCoordinates(selectedAdventure: selectedAdventure)
        
        if let lastCoordinate = adventureCoordinates.last {
            mapView.centerCoordinate = lastCoordinate
        }
        
        let polyline = MKPolyline(coordinates: adventureCoordinates, count: adventureCoordinates.count)
        self.mapView.addOverlay(polyline)
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
    }
}
