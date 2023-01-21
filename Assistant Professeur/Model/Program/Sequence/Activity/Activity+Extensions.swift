//
//  Activity+Extensions.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 18/01/2023.
//

import Foundation
import CoreData

/// Une séquence d'un programme scolaire pour une dscipline et un niveau donnés
extension ActivityEntity {

    // MARK: - Computed properties

    /// Wrapper of `name`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewName: String {
        get {
            self.name ?? ""
        }
        set {
            self.name = newValue
            try? ActivityEntity.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `number`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewNumber: Int {
        get {
            Int(self.number)
        }
        set {
            self.number = Int16(newValue)
            try? ActivityEntity.saveIfContextHasChanged()
        }
    }

    /// Durée estimée de l'activité en nombre de séances
    /// Wrapper of `duration`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewDuration: Double {
        get {
            self.duration
        }
        set {
            self.duration = newValue
            try? ActivityEntity.saveIfContextHasChanged()
        }
    }

    /// True si l'activité est une évaluation
    /// Wrapper of `isEval`
    /// - Important: *Saves the context to the store after modification is done*
    var viewIsEval: Bool {
        get {
            self.isEval
        }
        set {
            self.isEval = newValue
            try? ActivityEntity.saveIfContextHasChanged()
        }
    }
}

// MARK: - Extension Core Data

extension ActivityEntity: ModelEntityP {

}


// MARK: - Extension Debug

extension ActivityEntity {
    public override var description: String {
        """

        ACTIVITÉ: \(viewName)
           Numéro : \(viewNumber)
           Nom    : \(viewName)
           URL    : \(String(describing: url))
        """
    }
}
