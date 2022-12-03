//
//  CoreDataManager.swift
//  MovieApp
//
//  Created by Mohammad Azam on 2/23/21.
//

import Foundation
import os
import CoreData
import SwiftUI

private let customLog = Logger(subsystem : "com.michaud.lionel.Assistant-Professeur",
                               category  : "CoreDataController")

/// Class to hold all the Persistence methods
class CoreDataController {

    // MARK: - SINGLETON

    /// A singleton for our entire app to use
    static let shared = CoreDataController()

    // MARK: - Type Poperties

    /// Storage for Core Data
    private let container: NSPersistentContainer

    // MARK: - Computed Properties

    /// The main queue’s managed object context
    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }

    // MARK: - Initilializer

    /// An initializer to load Core Data
    private init() {
        container = NSPersistentContainer(name: "AppModel")
        container.loadPersistentStores { (description, error) in
            if let error {
                fatalError("Failed to initialize Core Data \(error.localizedDescription)")
            }
        }
        
        let directories = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        print(directories[0])
    }
    
    // MARK: - Methods

    /// Creates an NSManagedObject of **ANY** type
    ///
    /// Usage:
    ///
    ///     // create an item in CoreDataController context
    ///     let item: EntityObject = CoreDataController.shared.create()
    ///
    func create<T: NSManagedObject>() -> T {
        T(context: viewContext)
        //For adding Defaults see the `extension` all the way at the bottom of this post
    }

    /// Deletes  an NSManagedObject of any type
    ///
    /// Usage:
    ///
    ///     let item: EntityObject = CoreDataController.shared.create()
    ///
    ///     // delete the item from CoreDataController context
    ///     CoreDataController.shared.delete(item)
    ///
    func delete(_ obj: NSManagedObject){
        viewContext.delete(obj)
        try? saveIfContextHasChanged()
    }

    func rollback(){
        viewContext.rollback()
        try? saveIfContextHasChanged()
    }

    /// Checks whether the context has changes.
    /// Attempts to commit unsaved changes to registered objects to the context’s parent store.
    ///
    /// Usage:
    ///
    ///     // commit unsaved changes to registered objects to the CoreDataController context's store
    ///     CoreDataController.shared.saveIfContextHasChanged()
    ///
    func saveIfContextHasChanged() throws {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                customLog.log(level: .fault, "Failed to save changes to Core Data container \(error.localizedDescription)")
                throw error
            }
        }
    }

}


