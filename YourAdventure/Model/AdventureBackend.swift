//
//  AdventureBackend.swift
//  YourAdventure
//
//  Created by Dominik Leszczyński on 27/05/2021.
//

import UIKit
import CoreData
import CoreLocation

struct AdventureBackend {
    
    //MARK: - Core Data
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var adventureArray: [Adventure] {
        get {
            return loadData()
        }
    }
    
    func loadData() -> [Adventure] {
        let request: NSFetchRequest<Adventure> = Adventure.fetchRequest()
        var adventureFetchArray = [Adventure]()
        do {
            adventureFetchArray = try context.fetch(request)
        } catch {
            print("Error fetching data from database \(error)")
        }
        return adventureFetchArray.reversed()
    }
    func saveData(coordinates: [CLLocationCoordinate2D], distanceValue: Int, timeValue: Double, speedValue: Double, typeIndex: Int) {
        //        Save Stats to CoreData
        
        let userLocationsArray = getUserLocation(from: coordinates)
        
        let newAdventure = Adventure(context: context)
        newAdventure.date = Date()
        newAdventure.distance = Int32(distanceValue)
        newAdventure.time = timeValue
        newAdventure.speed = speedValue
        newAdventure.type = getAdventureTypeName(segmentIndex: typeIndex)
        for location in userLocationsArray {
            location.parentAdventure = newAdventure
            newAdventure.addToLocations(
                location
            )
        }
        saveContext()
    }
    func saveContext() {
        do {
            try self.context.save()
        } catch {
            print("Error saving data: \(error)")
        }
    }
    func loadCoordinates(selectedAdventure: Adventure) -> [CLLocationCoordinate2D] {
        
        var locationArray = [CLLocationCoordinate2D]()
        
        if let userLocationArray = selectedAdventure.locations?.allObjects as? [UserLocation] {
            
            for userLocation in userLocationArray {
                let location = CLLocationCoordinate2D(latitude: userLocation.latitude, longitude: userLocation.longitude)
                locationArray.append(location)
            }
        }
        
        return locationArray
        
    }
    
    func deleteDataAt(indexPath: IndexPath) {
        context.delete(adventureArray[indexPath.row])
        saveContext()
    }
    
    func getUserLocation(from coordinates: [CLLocationCoordinate2D]) -> [UserLocation] {
        var userLocations = [UserLocation]()
        for coordinate in coordinates {
            let userLocation = UserLocation(context: self.context)
            userLocation.latitude = coordinate.latitude
            userLocation.longitude = coordinate.longitude
            
            userLocations.append(userLocation)
        }
        return userLocations
    }
    
    //MARK: - Calculate Speed
    
    func calculateSpeed(distanceInt: Int, time: Double) -> Double {
        let distance = Double(distanceInt)
        let speedUnrounded = distance/time
//        Multiply by 10, round and divide by 10
        let speed = ((speedUnrounded * 10).rounded()/10)
        
//        in m/s
        return speed
        
    }
    
    func calculateAvgSpeed() -> String {
        var totalSpeed: Double = 0
        for adventure in adventureArray {
            totalSpeed += adventure.speed
        }
        let avgSpeed = totalSpeed / Double(adventureArray.count)
        
        return String(format: "%.1f", avgSpeed)
    }
    
    //MARK: - Calculate Type Percentage
    
    func calculateAdventureTypePercentage() -> [String: Double] {
//        Calculate Percentage for every Adventure type.
        let totalAdventures = Double(adventureArray.count)
        var dict: [String: Double] = ["Bike": 0, "On Foot": 0, "Car": 0]
        for adventure in adventureArray {
            switch adventure.type {
            case "Bike":
                dict["Bike"]! += 1
            case "On Foot":
                dict["On Foot"]! += 1
            default:
                dict["Car"]! += 1
            }
        }
        var dictPercentage = [String: Double]()
        for type in dict {
            dictPercentage[type.key] = ((type.value / totalAdventures) * 100)
        }
        return dictPercentage
    }
    
    //MARK: - Get Adventure Type
    
    func getAdventureTypeName(segmentIndex: Int) -> String {
//        Return Name of Adventure Type based on typeSegmentedControl Index.
        switch segmentIndex {
        case 0:
            return "Bike"
        case 1:
            return "On Foot"
        default:
            return "Car"
        }
    }
    
    func getAdventureTypeImage(stringName: String) -> String {
//        Return Image of Adventure Type based on its string name.
        switch stringName {
        case "Bike":
            return "bicycle"
        case "On Foot":
            return "figure.walk"
        default:
            return "car"
        }
    }
    
    func getFavoriteType(typeDictionary: [String: Double]) -> String {
//        Sort types dictionary based on its values to get the name of the most used one.
        let sortedTypeDict = typeDictionary.sorted { $0.1 > $1.1 }
        
        let favoriteType = sortedTypeDict.first?.key ?? "error"
        
        return favoriteType
    }
}
