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
                               category  : "CoreDataManager")

class CoreDataManager {

    // MARK: - SINGLETON

    // A singleton for our entire app to use
    static let shared = CoreDataManager()

    // MARK: - Type Poperties

    // Storage for Core Data
    private let persistentContainer: NSPersistentContainer

    // MARK: - Computed Properties

    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    // MARK: - Initilializer

    /// An initializer to load Core Data
    private init() {
        persistentContainer = NSPersistentContainer(name: "AppModel")
        persistentContainer.loadPersistentStores { (description, error) in
            if let error {
                fatalError("Failed to initialize Core Data \(error.localizedDescription)")
            }
        }
        
        let directories = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        print(directories[0])
    }
    
    // MARK: - Methods

    /// Checks whether the context has changes and commits them if needed.
    func save() throws {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                customLog.log(level: .fault, "Echec de l'enregistrement des modifications de la BDD \(error.localizedDescription)")
                throw error
            }
        }
    }

}


