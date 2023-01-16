//
//  Ressource+extensions.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 21/12/2022.
//

import Foundation
import CoreData

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
}

// MARK: - Extension Core Data

extension RessourceEntity: ModelEntityP {

    // MARK: - Type Methods

    @discardableResult
    static func create(
        dans school : SchoolEntity,
        withName    : String = "",
        quantity    : Int    = 1
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

    static func checkConsistency(errorFound: inout Bool) {
        all().forEach { ressource in
            guard ressource.school != nil else {
                errorFound = true
                return
            }
        }
    }

    // MARK: - Methods

    public override func awakeFromInsert() {
        super.awakeFromInsert()
        //Set defaults here
        // self.date = Date.now
    }

}

// MARK: - Extension Debug

extension RessourceEntity {
    public override var description: String {
        """

        RESSOURCE: \(viewName)
           Quantité   : \(quantity)
        """
    }
}
