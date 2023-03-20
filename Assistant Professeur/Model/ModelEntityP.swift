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
    // MARK: - Type Methods

    /// Returns an array of all objects of type `Self` in the persistent store
    /// - Returns: Array of all items in the persistent store
    static func all() -> [Self]

    static func byObjectId(id: NSManagedObjectID) -> Self?

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
    static var viewContext: NSManagedObjectContext {
        CoreDataManager.shared.viewContext
    }

    // MARK: - Type Methods

    /// Returns an array of all objects of type `Self` in the persistent store
    static func all() -> [Self] {
        let fetchRequest: NSFetchRequest<Self> = NSFetchRequest(entityName: String(describing: Self.self))

        do {
            return try viewContext.fetch(fetchRequest)
        } catch {
            return []
        }
    }

    /// Returns the number of elements of type `Self` in the persistent store
    static func cardinal() -> Int {
        Self.all().count
    }

    static func byObjectId(id: NSManagedObjectID) -> Self? {
        do {
            return try viewContext.existingObject(with: id) as? Self
        } catch {
            customLog.log(level: .error, "Objet \(Self.self) non trouvé: \(error.localizedDescription)")
            return nil
        }
    }

    /// Creates a sample Object in the Context
    static func create() -> Self {
        let newItem = Self(context: viewContext)
        return newItem
    }

    /// Remove all the object of type `Self` from its persistent store
    static func deleteAll() throws {
        try Self.viewContext.performAndWait {
            Self.all().forEach { item in
                Self.viewContext.delete(item)
            }
            try Self.saveIfContextHasChanged()
        }
    }

    static func rollback() {
        Self.viewContext.rollback()
        try? Self.saveIfContextHasChanged()
    }

    /// Checks whether the context has changes and commits them if needed.
    ///
    /// Seulement si des changements ont été opérés.
    static func saveIfContextHasChanged() throws {
        if Self.viewContext.hasChanges {
            do {
                try Self.viewContext.save()
            } catch {
                customLog.log(level: .fault, "Echec de l'enregistrement des modifications de la BDD: \(error.localizedDescription)")
                throw error
            }
        }
    }

    // MARK: - Methods

    /// Remove the object `self` from its persistent store and saves the changes to the persistent store
    func delete() throws {
        Self.viewContext.delete(self)
        try Self.saveIfContextHasChanged()
    }

    func refresh() {
        Self.viewContext.refresh(self, mergeChanges: false)
    }
}
