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

    public override func awakeFromInsert() {
        super.awakeFromInsert()
        //Set defaults here
        self.id = UUID()
    }

    // MARK: - Type Methods

    static func byId(id: UUID) -> Self? {
        all().first { object in
            object.id == id
        }
    }

    /// Créer une nouvelle instance et la sauvegarder dans le context
    @discardableResult
    static func create(
        name          : String = "",
        annotation    : String = "",
        duration      : Double = 1,
        isEval        : Bool   = false,
        dans sequence : SequenceEntity
    ) -> ActivityEntity {
        let nbSeqInProgram = sequence.nbOfActivities
        let activity = ActivityEntity.create()
        // Séquence d'appartenance.
        // mandatory
        activity.sequence = sequence

        activity.name       = name
        activity.number     = Int16(nbSeqInProgram + 1)
        activity.annotation = annotation
        activity.duration   = duration
        activity.isEval     = isEval

        try? Self.saveIfContextHasChanged()
        return activity
    }

    static func checkConsistency(errorFound: inout Bool) {
        all().forEach { activity in
            guard activity.sequence != nil else {
                errorFound = true
                return
            }
        }
    }
}

// MARK: - Extension Debug

extension ActivityEntity {
    public override var description: String {
        """

        ACTIVITÉ:
           Numéro : \(viewNumber)
           Nom    : \(viewName)
           Durée  : \(viewDuration) séances
           Eval   : \(isEval.frenchString)
           URL    : \(String(describing: url))
        """
    }
}
