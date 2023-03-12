//
//  CoreDataManager.swift
//  MovieApp
//
//  Created by Mohammad Azam on 2/23/21.
//

import CoreData
import Foundation
import os
import SwiftUI

private let customLog = Logger(
    subsystem: "com.michaud.lionel.Assistant-Professeur",
    category: "CoreDataController"
)

/// Class to hold all the Persistence methods
class CoreDataController {
    // MARK: - SINGLETON

    /// A singleton for our entire app to use
    static let shared = CoreDataController()

    // MARK: - Type Poperties

    /// Storage for Core Data
    private let container: NSPersistentCloudKitContainer

    // MARK: - Computed Properties

    /// The main queue’s managed object context
    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }

    // MARK: - Initilializer

    /// An initializer to load Core Data
    private init() {
        // Register value transformers
//        ValueTransformer.setValueTransformer(
//            ExamStepsTransformer(),
//            forName: .examStepsTransformer
//        )

        container = NSPersistentCloudKitContainer(name: "AppModel")

        // set History Tracking
        container
            .persistentStoreDescriptions
            .first!
            .setOption(
                true as NSNumber,
                forKey: NSPersistentHistoryTrackingKey
            )

        // set merge policy
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true

        container
            .loadPersistentStores { _, error in
                if let error {
                    customLog.log(
                        level: .fault,
                        "Failed to load the persistence store form Core Data: \(error.localizedDescription)"
                    )
                } else {
                    #if DEBUG
                        print("Loading of the persistent stores has completed")
                    #endif
                }
            }

        // Only initialize the schema when building the app with the
        // Debug build configuration.
        #if DEBUG
            do {
                // Use the container to initialize the development schema.
                try container.initializeCloudKitSchema(
                    options: []
                    // options: [.printSchema]
                )
                print("Initialization of the development schema completed")
            } catch {
                // Handle any errors.
                customLog.log(
                    level: .error,
                    "Failed to initialize the development schema in ClouKit: \(error.localizedDescription)"
                )
            }

            /// TODO: - DEBUG
            let directories = NSSearchPathForDirectoriesInDomains(
                .documentDirectory,
                .userDomainMask,
                true
            )
            print("Document directory: \(directories[0])")
        #endif
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
        // For adding Defaults see the `extension` all the way at the bottom of this post
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
    func delete(_ obj: NSManagedObject) throws {
        viewContext.delete(obj)
        try saveIfContextHasChanged()
    }

    func rollback() {
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
