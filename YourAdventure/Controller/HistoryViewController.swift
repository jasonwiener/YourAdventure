//
//  HistoryViewController.swift
//  YourAdventure
//
//  Created by Dominik Leszczyński on 18/04/2021.
//

import UIKit
import SwipeCellKit

class HistoryViewController: UIViewController {
    @IBOutlet weak var historyTableView: UITableView!
    @IBOutlet weak var uiNavigation: UINavigationItem!
    
    let formatter1 = DateFormatter()
    let shareFormatter = DateFormatter()
    var adventureBackend = AdventureBackend()
    var adventureArray = [Adventure]()
    var selectedAdventure = Adventure()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        historyTableView.dataSource = self
        historyTableView.delegate = self
        
        uiNavigation.title = Constants.Labels.historyText
        formatter1.dateFormat = "HH:mm EEEE, MMM d, yyyy"
        shareFormatter.dateFormat = "EEEE, MMM d"

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        adventureArray = adventureBackend.adventureArray
        historyTableView.reloadData()
    }

}

//MARK: - UITableView

extension HistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return adventureArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let adventureForCell = adventureArray[indexPath.row]
        //        Create TableViewCell with the choosen style
        
//        let cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: Constants.historyCellIndetifier)
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.historyCellIndetifier, for: indexPath) as! SwipeTableViewCell
        
        cell.delegate = self
        
        let date = adventureForCell.date ?? Date()
        let formattedDate = formatter1.string(from: date)
        
        guard let adventureType = adventureForCell.type else {fatalError("No adventure type.")}
        
        let imageSystemName = adventureBackend.getAdventureTypeImage(stringName: adventureType)
        
        cell.imageView?.image = UIImage(systemName: imageSystemName)
        
        cell.textLabel?.text = "\(formattedDate)"
        cell.detailTextLabel?.text = "Distance: \(adventureForCell.distance)m, Time: \(adventureForCell.time)s, Avg Speed: \(adventureForCell.speed)m/s"
        cell.backgroundColor = UIColor.clear
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.selectedAdventure = adventureArray[indexPath.row]
        
//        Deselect the cell user clicked on
        tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
        performSegue(withIdentifier: Constants.historyMapSegue, sender: nil)
    }
}

//MARK: - SwipeCellKit

extension HistoryViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        if orientation == .right {
            
            let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
                self.adventureBackend.deleteDataAt(indexPath: indexPath)
                self.adventureArray.remove(at: indexPath.row)
                
            }
            
            // customize the action appearance
            deleteAction.image = UIImage(systemName: "trash")
            
            return [deleteAction]
        } else if orientation == .left {
            
            let shareAction = SwipeAction(style: .default, title: "Share") { action, indexPath in
                let adventureToShare = self.adventureArray[indexPath.row]
                self.shareAdventure(adventure: adventureToShare)
                
            }
            
            // customize the action appearance
            shareAction.image = UIImage(systemName: "square.and.arrow.up")
            shareAction.backgroundColor = UIColor(named: Constants.Colors.share)
            
            return [shareAction]
        } else {
            return nil
        }
    }
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        if orientation == .right {
            options.expansionStyle = .destructive
            return options
        } else {
            return options
        }
    }
    
}

//MARK: - ShareAction

extension HistoryViewController {
    func shareAdventure(adventure: Adventure) {
        // text to share
        let formattedDate = shareFormatter.string(from: adventure.date!)
        let text = "My \(adventure.type!) journey on \(formattedDate), it took \(adventure.time) seconds, and \(adventure.distance) meters."
        // set up activity view controller
        let textToShare = [ text ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop ]
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }
}

//MARK: - PrepareForHistoryMapSegue

extension HistoryViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        Send recorded distance and time to the ResultsParentViewController
//        Then ResultsParentViewController will pass it to ResultsViewController
        if segue.identifier == Constants.historyMapSegue {
            let destinationVC = segue.destination as! HistoryMapViewController
            
            destinationVC.selectedAdventure = self.selectedAdventure
        }
    }
}
