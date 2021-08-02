//
//  SettingsViewController.swift
//  YourAdventure
//
//  Created by Dominik Leszczyński on 18/04/2021.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var themesTableView: UITableView!
    @IBOutlet weak var unitSegmentedControl: UISegmentedControl!
    
    let defaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        themesTableView.dataSource = self
        themesTableView.delegate = self
        
        themesTableView.separatorStyle = .none
        

        
        
        if defaults.string(forKey: Constants.UserDefaults.units) == Constants.UserDefaults.meters {
            unitSegmentedControl.selectedSegmentIndex = 0
        } else {
            unitSegmentedControl.selectedSegmentIndex = 1
        }
        
//        Set unitSegmentedControll to the current tintColor
        unitSegmentedControl.selectedSegmentTintColor = self.view.tintColor
    }
    
    @IBAction func unitSegmentedControllValueChanged(_ sender: UISegmentedControl) {
//        Change from Km To Imperial here or vice versa
        let selectedUnitsIndex = sender.selectedSegmentIndex
        let selectedUnits = sender.titleForSegment(at: selectedUnitsIndex)
        self.defaults.setValue(selectedUnits, forKey: Constants.UserDefaults.units)
        print(selectedUnits ?? "error")
    }
    

}

//MARK: - UITableView

extension SettingsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Constants.Colors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //        Create TableViewCell with the choosen style
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: Constants.themesCellIndentifier)
        
        let cellTheme = Constants.Colors.array[indexPath[1]]
        cell.textLabel?.text = cellTheme.capitalized
        if let cellColor = Constants.Colors.names[cellTheme] {
            cell.textLabel?.textColor = UIColor.init(named: cellColor)
            if view.tintColor.debugDescription.contains(cellColor) {
                cell.accessoryType = .checkmark
            }
        }
        cell.detailTextLabel?.text = Constants.Colors.themeName
        cell.backgroundColor = UIColor.clear
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let selectedTheme = tableView.cellForRow(at: indexPath)?.textLabel?.text?.lowercased() {
            if let selectedColor = Constants.Colors.names[selectedTheme] {
                
//                Set selected color as a global tint color
                self.defaults.set(selectedColor, forKey: Constants.UserDefaults.color)
                (tableView.cellForRow(at: indexPath) as! UIView).window?.tintColor = UIColor.init(named: selectedColor)
                unitSegmentedControl.selectedSegmentTintColor = self.view.tintColor
                
            }
        }
        
//        Deselect the cell user clicked on
        tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
        
//        Remove accessoryType for every cell
        for cell in tableView.visibleCells {
            cell.accessoryType = .none
        }
        
//        Add a checkmark for selected cell
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    }
}
