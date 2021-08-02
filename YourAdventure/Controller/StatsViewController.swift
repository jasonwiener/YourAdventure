//
//  StatsViewController.swift
//  YourAdventure
//
//  Created by Dominik Leszczyński on 18/04/2021.
//

import UIKit
import Charts

class StatsViewController: UIViewController {

    @IBOutlet weak var pieChartView: PieChartView!
    @IBOutlet weak var barChartView: BarChartView!
    @IBOutlet weak var favoriteLabel: UILabel!
    
    var adventureBackend = AdventureBackend()
    var adventureArray = [Adventure]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        Label customization
        favoriteLabel.adjustsFontSizeToFitWidth = true
        
        pieChartView.delegate = self
        barChartView.delegate = self
        
//        Charts customization
        barChartView.pinchZoomEnabled = false
        barChartView.doubleTapToZoomEnabled = false
        barChartView.rightAxis.enabled = false
        barChartView.leftAxis.enabled = false
        barChartView.xAxis.drawGridLinesEnabled = false
        barChartView.leftAxis.drawGridLinesEnabled = false
        barChartView.legend.font = UIFont.systemFont(ofSize: 15.0)
        barChartView.xAxis.enabled = false
//        barChartView.xAxis.labelPosition = XAxis.LabelPosition.bottom
        barChartView.animate(yAxisDuration: 1.4, easingOption: .easeOutBack)
        
        pieChartView.drawHoleEnabled = false
        pieChartView.legend.enabled = false
        pieChartView.animate(yAxisDuration: 2.4, easingOption: .easeOutBack)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        adventureArray = adventureBackend.adventureArray
        self.updateChartsAndLabels()
    }
    

}

extension StatsViewController: ChartViewDelegate {
    func updateChartsAndLabels() {
            DispatchQueue.main.async {
                
                let pieChartValues = self.adventureBackend.calculateAdventureTypePercentage()
                
                if self.adventureArray.isEmpty {
                    self.favoriteLabel.text = Constants.Labels.emptyStatsText
                } else {
                    self.favoriteLabel.text = "Your Favorite: \(self.adventureBackend.getFavoriteType(typeDictionary: pieChartValues)), Avg speed: \(self.adventureBackend.calculateAvgSpeed()) m/s"
                }
                
                var pieChartDataEntrySet: [PieChartDataEntry] = []
                
                for value in pieChartValues {
                    pieChartDataEntrySet.append(PieChartDataEntry(value: value.value, label: value.key))
                }
                
                let pieChartDataSet = PieChartDataSet(entries: pieChartDataEntrySet, label: "Favorite")
                pieChartDataSet.colors = ChartColorTemplates.material()
                
                let pieChartData = PieChartData(dataSet: pieChartDataSet)
                
                let pFormatter = NumberFormatter()
                pFormatter.numberStyle = .percent
                pFormatter.maximumFractionDigits = 1
                pFormatter.multiplier = 1
                pFormatter.percentSymbol = "%"
                
                self.pieChartView.data = pieChartData
                
                self.pieChartView.data?.setValueFormatter(DefaultValueFormatter(formatter: pFormatter))
                
                
                //            Create empty distanceChartDataEntry array
                var distanceChartDataSet: [BarChartDataEntry] = []
                
                //            Fill the array with ChartData
                
                let tenLastAdventures = self.adventureArray.suffix(10)
                var adventureCount = 0
                for adventureValue in tenLastAdventures {
                    distanceChartDataSet.append(BarChartDataEntry(x: Double(adventureCount), y: Double(adventureValue.distance)))
                    adventureCount += 1
                }
                let distanceSet = BarChartDataSet(entries: distanceChartDataSet, label: Constants.Labels.barChartText)
                
                distanceSet.colors = ChartColorTemplates.vordiplom()
                let distanceChartData = BarChartData(dataSet: distanceSet)
                
                
                self.barChartView.data = distanceChartData
                self.barChartView.fitScreen()
            }
        }
}
