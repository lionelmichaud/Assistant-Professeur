//
//  Activity+Extensions.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 18/01/2023.
//

import CoreData
import Foundation

/// Une séquence d'un programme scolaire pour une dscipline et un niveau donnés
extension ActivityEntity {
    // MARK: - Type Constants

    static let evalSommativeSymbol = "clock.badge.checkmark"
    static let evalFormativeSymbol = "text.badge.checkmark"
    static let tpSymbol = "testtube.2"
    static let projectSymbol = "wrench.and.screwdriver"

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

    /// Wrapper of `annotation`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewAnnotation: String {
        get {
            self.annotation ?? ""
        }
        set {
            self.annotation = newValue
            try? Self.saveIfContextHasChanged()
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

    /// True si l'activité inclue une évaluation sommative
    /// Wrapper of `isEval`
    /// - Important: *Saves the context to the store after modification is done*
    var viewIsEvalSommative: Bool {
        get {
            self.isEval
        }
        set {
            self.isEval = newValue
            try? ActivityEntity.saveIfContextHasChanged()
        }
    }

    /// True si l'activité inclue une évaluation formative
    /// Wrapper of `isEvalFormative`
    /// - Important: *Saves the context to the store after modification is done*
    var viewIsEvalFormative: Bool {
        get {
            self.isEvalFormative
        }
        set {
            self.isEvalFormative = newValue
            try? ActivityEntity.saveIfContextHasChanged()
        }
    }

    /// True si l'activité inclue un TP
    /// Wrapper of `isTP`
    /// - Important: *Saves the context to the store after modification is done*
    var viewIsTP: Bool {
        get {
            self.isTP
        }
        set {
            self.isTP = newValue
            try? ActivityEntity.saveIfContextHasChanged()
        }
    }
    /// True si l'activité fait partie d'un Projet
    /// Wrapper of `isProject`
    /// - Important: *Saves the context to the store after modification is done*
    var viewIsProject: Bool {
        get {
            self.isProject
        }
        set {
            self.isProject = newValue
            try? ActivityEntity.saveIfContextHasChanged()
        }
    }
}

// MARK: - Extension Core Data

extension ActivityEntity: ModelEntityP {
    override public func awakeFromInsert() {
        super.awakeFromInsert()
        // Set defaults here
        self.id = UUID()
    }

    // MARK: - Type Methods

    static func byId(id: UUID) -> Self? {
        all().first { object in
            object.id == id
        }
    }

    /// Créer une nouvelle instance SANS la sauvegarder dans le context
    static func createWithoutSaving(
        name: String = "",
        annotation: String = "",
        url: URL? = nil,
        duration: Double = 1,
        isEvalSommative: Bool = false,
        isEvalFormative: Bool = false,
        isTP: Bool = false,
        isProject: Bool = false,
        dans sequence: SequenceEntity
    ) -> ActivityEntity {
        let nbActInProgram = sequence.nbOfActivities
        let activity = ActivityEntity.create()
        // Séquence d'appartenance.
        // mandatory
        activity.sequence = sequence

        activity.name = name
        activity.number = Int16(nbActInProgram + 1)
        activity.annotation = annotation
        activity.url = url
        activity.duration = duration
        activity.isEval = isEvalSommative
        activity.isEvalFormative = isEvalFormative
        activity.isTP = isTP
        activity.isProject = isProject

        return activity
    }

    /// Créer une nouvelle instance ET la sauvegarder dans le context
    @discardableResult
    static func create(
        name: String = "",
        annotation: String = "",
        url: URL? = nil,
        duration: Double = 1,
        isEvalSommative: Bool = false,
        isEvalFormative: Bool = false,
        isTP: Bool = false,
        isProject: Bool = false,
        dans sequence: SequenceEntity
    ) -> ActivityEntity {
        let newActivity = createWithoutSaving(
            name: name,
            annotation: annotation,
            url: url,
            duration: duration,
            isEvalSommative: isEvalSommative,
            isEvalFormative: isEvalFormative,
            isTP: isTP,
            isProject: isProject,
            dans: sequence
        )

        try? Self.saveIfContextHasChanged()
        return newActivity
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

public extension ActivityEntity {
    override var description: String {
        """

        ACTIVITÉ:
           Numéro : \(self.viewNumber)
           Nom    : \(self.viewName)
           Durée  : \(self.viewDuration) séances
           Eval   : \(isEval.frenchString)
           URL    : \(String(describing: url))
        """
    }
}
