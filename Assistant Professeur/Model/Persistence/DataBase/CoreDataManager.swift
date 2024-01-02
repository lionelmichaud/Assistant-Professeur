//
//  CoreDataManager.swift
//  MovieApp
//
//  Created by Mohammad Azam on 2/23/21.
//

import AppFoundation
import CoreData
import Foundation
import OSLog
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
    private var cloudKitContainer: NSPersistentCloudKitContainer

    #if DEBUG
        /// In memory storage for Previews and Tests Core Data
        private var inMemoryContainer: NSPersistentContainer
    #endif

    // MARK: - Computed Properties

    /// The main queue’s managed object context for Views only
    private var viewContext: NSManagedObjectContext {
        return cloudKitContainer.viewContext
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
            customLog.info(">> CoreDataManager.init() initialization has started")
        #endif

        guard let url = Bundle.main.url(
            forResource: CoreDataManager.modelName,
            withExtension: "momd"
        ) else {
            fatalError("Failed to locate momd file for \(CoreDataManager.modelName)")
        }

        guard let coreDataModel = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Failed to load momd file for \(CoreDataManager.modelName)")
        }

        #if DEBUG
            inMemoryContainer = NSPersistentContainer(
                name: CoreDataManager.modelName,
                managedObjectModel: coreDataModel
            )
        #endif

        cloudKitContainer = NSPersistentCloudKitContainer(
            name: CoreDataManager.modelName,
            managedObjectModel: coreDataModel
        )

        initializeTransformers()

        #if DEBUG
            initializeInMemoryContainer()
        #endif

        initializePersitentContainer()

        // Debug build configuration.
        #if DEBUG
            customLog.info(
                ">> CoreDataManager.init() initialization has completed"
            )
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

    // Debug build configuration.
    #if DEBUG
        /// Initialization of the 'in memory' Container for Previews and Tests.
        ///
        /// Shall be done in development build only.
        private func initializeInMemoryContainer() {
            inMemoryContainer.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
            inMemoryContainer.loadPersistentStores { _, error in
                if let error = error as NSError? {
                    customLog.fault(
                        "Failed to load the persistence store from Core Data: \(error.localizedDescription)"
                    )
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            }
            inMemoryContainer.viewContext.automaticallyMergesChangesFromParent = true
        }
    #endif

    /// Initialization of the 'persitent' Container for Views.
    ///
    /// This container is synchronized with CloudKit.
    private func initializePersitentContainer() {
        // define the URL for the SQL database storage
        let appSupportUrl = URL.applicationSupportDirectory
        let databaseUrl = appSupportUrl.appending(component: CoreDataManager.modelName + ".sqlite")

        // set History Tracking
        if let description = cloudKitContainer.persistentStoreDescriptions.first {
            // Imposer l'URL de la base de données SQL pour assurer que c'est la même pour la SwiftData stack
            description.url = databaseUrl
            description.setOption(
                true as NSNumber,
                forKey: NSPersistentHistoryTrackingKey
            )
            // print("URL = \(String(describing: description.url?.absoluteString))")
        }

        // set merge policy
        cloudKitContainer.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        cloudKitContainer.viewContext.automaticallyMergesChangesFromParent = true

        // load the content of the persistent store (empty if .inMemory)
        cloudKitContainer.loadPersistentStores { _, error in
            if let error {
                AppState.shared.initError = AppInitError.failedToLoadPersistentStores
                customLog.fault(
                    "Failed to load the persistence store from Core Data: \(error.localizedDescription)"
                )
                fatalError()
            } else {
                #if DEBUG
                    customLog.info(
                        ">> Loading of the persistent stores has completed"
                    )
                #endif
            }
        }
        // Only initialize the schema when building the app with the
        // Debug build configuration.
        #if DEBUG
            // LIGNE À DESACTIVER sous la cible "My Mac (Designed for iPad)"
            // initializeCloudKitSchema()
        #endif
    }

    #if DEBUG
        /// Initialization of the the CloudKit Schema from the App Schema.
        ///
        /// Shall be done in development build only.
        /// - Warning: Shall NOT BE DONE on MacOs (crashes).
        private func initializeCloudKitSchema() {
            do {
                // Use the container to initialize the development schema.
                try cloudKitContainer.initializeCloudKitSchema(
                    options: []
                    // options: [.printSchema]
                )
                customLog.info(">> Initialization of the development schema completed")
            } catch {
                // Handle any errors.
                AppState.shared.initError = AppInitError.failedToInitializeCloudKitSchema
                customLog.error(
                    ">> Failed to initialize the development schema in ClouKit: \(error.localizedDescription)"
                )
            }

            let directories = NSSearchPathForDirectoriesInDomains(
                .documentDirectory,
                .userDomainMask,
                true
            )
            customLog.info(">> Document directory: \(directories[0])")
        }
    #endif

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
                customLog.fault(
                    "Failed to save changes to Core Data container \(error.localizedDescription)"
                )
                throw error
            }
        }
    }
}
