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
    case inMemory
    case persisted
}

/// Class to hold all the Persistence methods
class CoreDataManager {
    // MARK: - SINGLETON

    /// Nom du model de données Core Data de l'appli
    private static let modelName = "AppModel"

    /// A singleton for our entire app to use
    static let shared = CoreDataManager()

    static var storeType: StoreType = .persisted

    static var managedObjectModel: NSManagedObjectModel = {
        let bundle = Bundle(for: CoreDataManager.self)

        guard let url = bundle.url(
            forResource: modelName,
            withExtension: "momd"
        ) else {
            fatalError("Failed to locate momd file for \(modelName)")
        }

        guard let model = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Failed to load momd file for \(modelName)")
        }

        return model
    }()

    // MARK: - Stored Poperties

    /// The main queue’s managed object context.
    ///
    /// Which context is returned depends on the value of the attribute `storeType`:
    ///  - either for Views
    ///  - or for Previews and Tests
    var context: NSManagedObjectContext {
        switch CoreDataManager.storeType {
            case .inMemory:
                #if DEBUG
                    return previewContext
                #else
                    fatalError()
                #endif

            case .persisted:
                return viewContext
        }
    }

    /// Persitent storage for Core Data synchronized with CloudKit
    private var persistentCloudKitContainer: NSPersistentCloudKitContainer

    #if DEBUG
        /// In memory storage for Previews and Tests Core Data
        private var inMemoryContainer: NSPersistentContainer
    #endif

    // MARK: - Computed Properties

    /// The main queue’s managed object context for Views only
    private var viewContext: NSManagedObjectContext {
        return persistentCloudKitContainer.viewContext
    }

    #if DEBUG
        /// The main queue’s managed object context for Previews and Tests only
        private var previewContext: NSManagedObjectContext {
            return inMemoryContainer.viewContext
        }
    #endif

    // MARK: - Initilializer

    /// An initializer to create containers and load Core Data.
    private init() {
        #if DEBUG
            print(">> CoreDataManager.init() initialization has started")
        #endif

        #if DEBUG
            inMemoryContainer =
                NSPersistentContainer(
                    name: CoreDataManager.modelName,
                    managedObjectModel: Self.managedObjectModel
                )
        #endif

        persistentCloudKitContainer =
            NSPersistentCloudKitContainer(
                name: CoreDataManager.modelName,
                managedObjectModel: Self.managedObjectModel
            )

        initializeTransformers()

        #if DEBUG
            initializeInMemoryContainer()
        #endif

        initializePersitentContainer()

        // Debug build configuration.
        #if DEBUG
            print(">> CoreDataManager.init() initialization has completed")
        #endif
    }

    /// Initialization of the transformers used on the CoreData entities.
    func initializeTransformers() {
        // Register value transformers
        //        ValueTransformer.setValueTransformer(
        //            ExamStepsTransformer(),
        //            forName: .examStepsTransformer
        //        )
    }

    #if DEBUG
        /// Initialization of the 'in memory' Container for Previews and Tests.
        ///
        /// Shall be done in development build only.
        private func initializeInMemoryContainer() {
            inMemoryContainer.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
            inMemoryContainer.loadPersistentStores { _, _ in }
        }
    #endif

    /// Initialization of the 'persitent' Container for Views.
    ///
    /// This container is synchronized with CloudKit.
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
            /// LIGNE À DESACTIVER sous la cible "My Mac (Designed for iPad)"
             initializeCloudKitSchema()
        #endif
    }

    /// Initialization of the the CloudKit Schema from the App Schema.
    ///
    /// Shall be done in development build only.
    /// - Warning: Shall NOT BE DONE on MacOs (crashes).
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
