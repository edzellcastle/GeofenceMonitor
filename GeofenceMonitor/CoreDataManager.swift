//
//  CoreDataManager.swift
//  GeofenceMonitor
//
//  Created by David Lindsay on 4/16/21.
//

import Foundation
import CoreData

public class CoreDataManager {

    public static let shared = CoreDataManager()

    let identifier: String  = "com.tapinfuse.CoreDataFramework"
    let model: String       = "CoreDataModel"                    

    lazy var persistentContainer: NSPersistentContainer = {

        let messageKitBundle = Bundle(identifier: self.identifier)
        let modelURL = messageKitBundle!.url(forResource: self.model, withExtension: "momd")!
        let managedObjectModel =  NSManagedObjectModel(contentsOf: modelURL)
        let container = NSPersistentContainer(name: self.model, managedObjectModel: managedObjectModel!)
            
        container.loadPersistentStores { (storeDescription, error) in
            if let err = error {
                fatalError("data store loading failed:\(err)")
            }
        }
            
        return container
    }()

    public func postLocation(userID: String, geofenceLatitude: Double, geofenceLongitude: Double, action: String){
        
        let context = persistentContainer.viewContext
        let contact = NSEntityDescription.insertNewObject(forEntityName: "LocationAction", into: context) as! LocationAction
        
        contact.userID = userID
        contact.geofenceLatitude = geofenceLatitude
        contact.geofenceLongitude = geofenceLongitude
        contact.action = action
        
        do {
            try context.save()
            print("Location posted succesfuly")
            
        } catch let error {
            print("Failed to create location: \(error.localizedDescription)")
        }
    }
    
    public func fetch() {
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<LocationAction>(entityName: "LocationAction")
        
        do {
            let locationActions = try context.fetch(fetchRequest)
            
            for (index,locationAction) in locationActions.enumerated() {
                print("Location Action \(index): \(locationAction.userID ?? "")")
            }
        } catch let fetchErr {
            print("Failed to fetch location actions:",fetchErr)
        }
    }

}

