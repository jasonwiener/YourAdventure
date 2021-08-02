//
//  ResultsParentViewController.swift
//  YourAdventure
//
//  Created by Dominik Leszczyński on 28/04/2021.
//

import UIKit
import CoreLocation.CLLocation

class ResultsParentViewController: UIViewController {
    
    var distanceValue:Int = 0
    var timeValue:Double = 0
    var coordinates = [CLLocationCoordinate2D]()
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
extension ResultsParentViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.resultsSegue {
            let destinationVC = segue.destination as! ResultsViewController
            
            destinationVC.distanceValue = distanceValue
            destinationVC.timeValue = timeValue
            destinationVC.coordinates = coordinates
        }
    }
}
