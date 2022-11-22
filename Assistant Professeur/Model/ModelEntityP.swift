//
//  BaseModel.swift
//  MovieApp
//
//  Created by Mohammad Azam on 3/11/21.
//

import Foundation
import os
import CoreData

private let customLog = Logger(subsystem : "com.michaud.lionel.Assistant-Professeur",
                               category  : "BaseModel")

protocol ModelEntityP: NSManagedObject {

    /// Remove the object `self` from its persistent store
    func delete() throws

    /// Remove all the object of type `Self` from its persistent store
    static func deleteAll() throws

    /// Checks whether the context has changes and commits them if needed.
    ///
    /// Seulement si des changements ont été opérés.
    static func save() throws

    /// Returns an array of all objects of type `Self` in the persistent store
    /// - Returns: Array of all items in the persistent store
    static func all() -> [Self]

    static func byId(id: NSManagedObjectID) -> Self?
}

extension ModelEntityP {

    // MARK: - Type Properties

    static var viewContext: NSManagedObjectContext {
        CoreDataManager.shared.viewContext
    }

    // MARK: - Type Methods

    /// Remove all the object of type `Self` from its persistent store
    static func deleteAll() throws {
        Self.all().forEach { item in
            Self.viewContext.delete(item)
        }
        try Self.save()
    }

    /// Returns an array of all objects of type `Self` in the persistent store
    /// - Returns: Array of all items in the persistent store
    static func all() -> [Self] {

        let fetchRequest: NSFetchRequest<Self> = NSFetchRequest(entityName: String(describing: Self.self))

        do {
            return try viewContext.fetch(fetchRequest)
        } catch {
            return []
        }
    }

    static func byId(id: NSManagedObjectID) -> Self? {
        do {
            return try viewContext.existingObject(with: id) as? Self
        } catch {
            print(error)
            return nil
        }
    }

    /// Checks whether the context has changes and commits them if needed.
    ///
    /// Seulement si des changements ont été opérés.
    static func save() throws {
        if Self.viewContext.hasChanges {
            do {
                try Self.viewContext.save()
            } catch {
                customLog.log(level: .fault, "Echec de l'enregistrement des modifications de la BDD \(error.localizedDescription)")
                throw error
            }
        }
    }

    // MARK: - Methods

    /// Remove the object `self` from its persistent store
    func delete() throws {
        Self.viewContext.delete(self)
        try Self.save()
    }

}
