//
//  BaseModel.swift
//  MovieApp
//
//  Created by Mohammad Azam on 3/11/21.
//

import CoreData
import Foundation
import os

private let customLog = Logger(
    subsystem: "com.michaud.lionel.Assistant-Professeur",
    category: "ModelEntityP"
)

protocol ModelEntityP: NSManagedObject {
    var id: UUID? { get set }

    // MARK: - Type Methods

    /// Returns the Managed Object Context depending on the storage location
    static var context: NSManagedObjectContext { get }

    /// Returns an array of all objects of type `Self` in the persistent store
    /// - Returns: Array of all items in the persistent store
    static func all() -> [Self]

    static func byObjectId(MngObjID: NSManagedObjectID) -> Self?

    static func byId(id: UUID) -> Self?

    static func managedObjectID(id: UUID?) -> NSManagedObjectID?

    /// Creates a sample Object in the Context
    static func create() -> Self

    /// Remove all the object of type `Self` from its persistent store
    static func deleteAll() throws

    /// Checks whether the context has changes and commits them if needed.
    ///
    /// Seulement si des changements ont été opérés.
    static func saveIfContextHasChanged() throws

    // MARK: - Methods

    /// Remove the object `self` from its persistent store
    func delete() throws
}

extension ModelEntityP {
    // MARK: - Type Methods

    /// Returns the Managed Object Context depending on the storage location
    static var context: NSManagedObjectContext {
        CoreDataManager.shared.context
    }

    /// Returns an array of all objects of type `Self` in the persistent store
    static func all() -> [Self] {
        let fetchRequest: NSFetchRequest<Self> = NSFetchRequest(entityName: String(describing: Self.self))

        do {
            return try context.fetch(fetchRequest)
        } catch {
            return []
        }
    }

    /// Returns the number of elements of type `Self` in the persistent store
    static func cardinal() -> Int {
        do {
            return try context.count(for: Self.fetchRequest())
        } catch {
            return 0
        }
    }

    static func byObjectId(MngObjID: NSManagedObjectID) -> Self? {
        do {
            return try context.existingObject(with: MngObjID) as? Self
        } catch {
            customLog.log(level: .error, "Objet \(Self.self) non trouvé: \(error.localizedDescription)")
            return nil
        }
    }

    static func byId(id: UUID) -> Self? {
        all().first { object in
            object.id == id
        }
    }

    static func managedObjectID(id: UUID?) -> NSManagedObjectID? {
        guard let id,
              let objectFound = byId(id: id) else {
            return nil
        }
        return objectFound.objectID
    }

    /// Creates a sample Object in the Context
    static func create() -> Self {
        let newItem = Self(context: context)
        return newItem
    }

    /// Remove all the object of type `Self` from its persistent store
    static func deleteAll() throws {
        try Self.context.performAndWait {
            Self.all().forEach { item in
                Self.context.delete(item)
            }
            try Self.saveIfContextHasChanged()
        }
    }

    static func rollback() {
        Self.context.rollback()
        try? Self.saveIfContextHasChanged()
    }

    /// Checks whether the context has changes and commits them if needed.
    ///
    /// Seulement si des changements ont été opérés.
    static func saveIfContextHasChanged() throws {
        if Self.context.hasChanges {
            do {
                try Self.context.save()
            } catch {
                customLog.log(level: .fault, "Echec de l'enregistrement des modifications de la BDD: \(error.localizedDescription)")
                throw error
            }
        }
    }

    // MARK: - Methods

    /// Remove the object `self` from its persistent store and saves the changes to the persistent store
    func delete() throws {
        Self.context.delete(self)
        try Self.saveIfContextHasChanged()
    }

    func refresh() {
        Self.context.refresh(self, mergeChanges: false)
    }
}
