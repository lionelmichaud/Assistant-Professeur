//
//  Ressource+extensions.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 21/12/2022.
//

import CoreData
import Foundation

extension RessourceEntity {
    @objc
    var viewName: String {
        get {
            self.name ?? ""
        }
        set {
            self.name = newValue
        }
    }

    @objc
    var viewQuantity: Int {
        get {
            Int(self.quantity)
        }
        set {
            self.quantity = Int16(newValue)
        }
    }
}

// MARK: - Extension Core Data

extension RessourceEntity {
    // MARK: - Type Methods

    @discardableResult
    static func create(
        dans school: SchoolEntity,
        withName: String = "",
        quantity: Int = 1
    ) -> RessourceEntity {
        let ressource = RessourceEntity.create()
        // Etablissement d'appartenance.
        // mandatory
        ressource.school = school

        ressource.name = withName
        ressource.quantity = Int16(quantity)

        try? RessourceEntity.saveIfContextHasChanged()
        return ressource
    }

    /// Check the correctness and consistency of all database entities of this type.
    /// - Parameters:
    ///   - errorList: Liste des erreurs trouvées.
    static func checkConsistency(
        errorList: inout DataBaseErrorList,
        tryToRepair: Bool
    ) {
        all().forEach { ressource in
            if ressource.school == nil {
                if tryToRepair {
                    do {
                        // la destruction est sauvegardée
                        try ressource.delete()
                    } catch {
                        errorList.append(DataBaseError.noOwner(
                            entity: Self.entity().name!,
                            name: ressource.viewName,
                            id: ressource.id
                        ))
                    }
                } else {
                    errorList.append(DataBaseError.noOwner(
                        entity: Self.entity().name!,
                        name: ressource.viewName,
                        id: ressource.id
                    ))
                }
            }
            
            if ressource.viewQuantity.isNOZ {
                errorList.append(DataBaseError.outOfBound(
                    entity: Self.entity().name!,
                    name: ressource.viewName,
                    attribute: "quantity",
                    id: ressource.id
                ))
            }
        }
    }

    // MARK: - Methods

    override public func awakeFromInsert() {
        super.awakeFromInsert()
        // Set defaults here
        self.id = UUID()
    }
}

// MARK: - Extension Debug

public extension RessourceEntity {
    override var description: String {
        """

        RESSOURCE: \(viewName)
           Quantité   : \(quantity)
        """
    }
}
