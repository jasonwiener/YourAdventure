//
//  ResultsViewController.swift
//  YourAdventure
//
//  Created by Dominik Leszczyński on 23/04/2021.
//

import UIKit
import CoreLocation.CLLocation

class ResultsViewController: UIViewController {
    @IBOutlet weak var distanceValueLabel: UILabel!
    @IBOutlet weak var timeValueLabel: UILabel!
    @IBOutlet weak var speedValueLabel: UILabel!
    @IBOutlet weak var uiNavigation: UINavigationItem!
    @IBOutlet weak var typeSegmentedControl: UISegmentedControl!
    
//    Stat Values
    var distanceValue:Int = 0
    var timeValue:Double = 0
    var speedValue: Double = 0
    var coordinates = [CLLocationCoordinate2D]()
    
    var adventureBackend = AdventureBackend()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uiNavigation.title = Constants.Labels.resultsText
        
        distanceValueLabel.text = "\(distanceValue)m"
        timeValueLabel.text = "\(timeValue)s"
        
        speedValue = adventureBackend.calculateSpeed(
            distanceInt: distanceValue,
            time: timeValue
        )
        speedValueLabel.text = "\(speedValue) m/s"

        typeSegmentedControl.selectedSegmentTintColor = view.tintColor
    }
    
    //MARK: - DismissSegue
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        adventureBackend.saveData(
            coordinates: coordinates,
            distanceValue: distanceValue,
            timeValue: timeValue,
            speedValue: speedValue,
            typeIndex: typeSegmentedControl.selectedSegmentIndex
        )
        
        
        self.dismiss(animated: true, completion: nil)
    }
}
