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
    category: "CoreDataManager"
)

enum StoreType {
    case inMemory, persisted
}

/// Class to hold all the Persistence methods
class CoreDataManager {
    // MARK: - SINGLETON

    /// Nom du model de données Core Data de l'appli
    private static let modelName = "AppModel"

    /// A singleton for our entire app to use
    static let shared = CoreDataManager()

    static var storeType: StoreType = .persisted

    // MARK: - Stored Poperties

    /// Persitent storage for Core Data synchronized with CloudKit
    private var persistentCloudKitContainer: NSPersistentCloudKitContainer

    /// In memory storage for Previews and Tests Core Data
    private var inMemoryContainer: NSPersistentContainer

    // MARK: - Computed Properties

    /// The main queue’s managed object context for View only
    var viewContext: NSManagedObjectContext {
        return persistentCloudKitContainer.viewContext
    }

    /// The main queue’s managed object context for Previews and Tests only
    var previewContext: NSManagedObjectContext {
        return inMemoryContainer.viewContext
    }

    var context: NSManagedObjectContext {
        switch CoreDataManager.storeType {
            case .inMemory:
                return previewContext

            case .persisted:
                return viewContext
        }
    }

    // MARK: - Initilializer

    /// An initializer to create containers and load Core Data
    private init() {
        // ---------------------------------------------

        #if DEBUG
            print(">> CoreDataManager.init() initialization has started")
        #endif

        // Register value transformers
        //        ValueTransformer.setValueTransformer(
        //            ExamStepsTransformer(),
        //            forName: .examStepsTransformer
        //        )

        inMemoryContainer = NSPersistentContainer(name: CoreDataManager.modelName)
        persistentCloudKitContainer = NSPersistentCloudKitContainer(name: CoreDataManager.modelName)

        initializeInMemoryContainer()
        initializePersitentContainer()

        // Debug build configuration.
        #if DEBUG
            print(">> CoreDataManager.init() initialization has completed")
        #endif
    }

    private func initializeInMemoryContainer() {
        inMemoryContainer.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        inMemoryContainer.loadPersistentStores { _, _ in }
    }

    private func initializePersitentContainer() {
        // set History Tracking
        persistentCloudKitContainer
            .persistentStoreDescriptions
            .first!
            .setOption(
                true as NSNumber,
                forKey: NSPersistentHistoryTrackingKey
            )

        // set merge policy
        persistentCloudKitContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        persistentCloudKitContainer.viewContext.automaticallyMergesChangesFromParent = true

        // load the content of the persistent store (empty if .inMemory)
        persistentCloudKitContainer.loadPersistentStores { _, error in
            if let error {
                AppState.shared.initError = .failedToLoadPersistentStores
                customLog.log(
                    level: .fault,
                    "Failed to load the persistence store from Core Data: \(error.localizedDescription)"
                )
            } else {
                #if DEBUG
                    print(">> Loading of the persistent stores has completed")
                #endif
            }
        }
        // Only initialize the schema when building the app with the
        // Debug build configuration.
        #if DEBUG
            // LIGNE À DESACTIVER sous la cible "My Mac (Designed for iPad)"
             initializeCloudKitSchema()
        #endif
    }

    private func initializeCloudKitSchema() {
        do {
            // Use the container to initialize the development schema.
            try persistentCloudKitContainer.initializeCloudKitSchema(
                options: []
                // options: [.printSchema]
            )
            print(">> Initialization of the development schema completed")
        } catch {
            // Handle any errors.
            AppState.shared.initError = .failedToInitializeCloudKitSchema
            customLog.log(
                level: .error,
                ">> Failed to initialize the development schema in ClouKit: \(error.localizedDescription)"
            )
        }

        // TODO: - DEBUG
        let directories = NSSearchPathForDirectoriesInDomains(
            .documentDirectory,
            .userDomainMask,
            true
        )
        print(">> Document directory: \(directories[0])")
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
