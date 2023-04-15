//
//  colle+extensions.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 26/12/2022.
//

import CoreData
import Foundation
import SwiftUI

extension ColleEntity {
    // MARK: - Computed properties

    /// Wrapper of `motif`
    /// - Important: *Saves the context to the store after modification is done*
    var motifEnum: MotifEnum {
        get {
            MotifEnum(rawValue: motif) ?? .bavardage
        }
        set {
            if newValue != motifEnum {
                if newValue == .autre {
                    descriptionMotif = "description"
                }
            }
            self.motif = newValue.rawValue
            try? ObservEntity.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `descriptionMotif`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewDescriptionMotif: String {
        get {
            self.descriptionMotif ?? "description"
        }
        set {
            self.descriptionMotif = newValue
            try? ObservEntity.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `date`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewDate: Date {
        get {
            self.date ?? Date.now
        }
        set {
            self.date = newValue
            try? ColleEntity.saveIfContextHasChanged()
        }
    }

    var color: Color {
        satisfies(isConsignee: false) ? .red : .green
    }

    /// Wrapper of `duree`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewDuree: Int {
        get {
            Int(self.duree)
        }
        set {
            self.duree = Int16(newValue)
            try? ColleEntity.saveIfContextHasChanged()
        }
    }

    // MARK: - Methods

    /// Modifie l'attribut `motif`
    func setMotif(_ newMotif: MotifEnum) {
        self.motif = newMotif.rawValue
    }

    /// Toggle l'attribut `isConsignee` de la classe
    /// - Important: *Saves the context to the store after modification is done*
    func toggleIsConsignee() {
        isConsignee.toggle()
        try? ColleEntity.saveIfContextHasChanged()
    }

    /// Toggle l'attribut `isVerified` de la classe
    /// - Important: *Saves the context to the store after modification is done*
    func toggleIsVerified() {
        isVerified.toggle()
        try? ColleEntity.saveIfContextHasChanged()
    }

    /// - Parameters:
    ///   - isConsignee: si `nil`, le critère n'est pas pris en compe
    ///   - isVerified: si `nil`, le critère n'est pas pris en compe
    func satisfies(
        isConsignee: Bool? = nil,
        isVerified: Bool? = nil
    ) -> Bool {
        switch (isConsignee, isVerified) {
            case (nil, nil):
                return true

            case (.some(let c), nil):
                return self.isConsignee == c

            case (nil, let .some(v)):
                return self.isVerified == v

            case let (.some(c), .some(v)):
                return self.isConsignee == c || self.isVerified == v
        }
    }
}

// MARK: - Extension Core Data

extension ColleEntity {
    // MARK: - Type Computed Properties

    override public func awakeFromInsert() {
        super.awakeFromInsert()
        // Set defaults here
        //        self.fileName = ""
        self.date = Date.now
        self.id = UUID()
    }

    // MARK: - Type Methods

    @discardableResult
    static func create(
        pour eleve: EleveEntity,
        date: Date = Date.now,
        motifEnum: MotifEnum,
        descriptionMotif: String,
        isConsignee: Bool = false,
        isVerified: Bool = false,
        duree: Int = 1
    ) -> ColleEntity {
        let colle = ColleEntity.create()
        // Eleve d'appartenance.
        // mandatory
        colle.eleve = eleve

        colle.setMotif(motifEnum)
        colle.date = date
        colle.descriptionMotif = descriptionMotif
        colle.isConsignee = isConsignee
        colle.isVerified = isVerified
        colle.duree = Int16(duree)

        try? ColleEntity.saveIfContextHasChanged()
        return colle
    }

    /// Check the correctness and consistency of all database entities of this type.
    /// - Parameters:
    ///   - errorList: Liste des erreurs trouvées.
    static func checkConsistency(
        errorList: inout DataBaseErrorList,
        tryToRepair: Bool
    ) {
        all().forEach { colle in
            if colle.eleve == nil {
                if tryToRepair {
                    do {
                        // la destruction est sauvegardée
                        try colle.delete()
                    } catch {
                        errorList.append(DataBaseError.noOwner(
                            entity: Self.entity().name!,
                            name: colle.viewDate.stringMediumDate,
                            id: colle.id
                        ))
                    }
                } else {
                    errorList.append(DataBaseError.noOwner(
                        entity: Self.entity().name!,
                        name: colle.viewDate.stringMediumDate,
                        id: colle.id
                    ))
                }
            }
        }
    }
}

// MARK: - Extension Debug

public extension ColleEntity {
    override var description: String {
        """

        COLLE:
           Eleve         : \(String(describing: eleve?.displayName))
           Date          : \(date.stringShortDate)
           Motif         : \(motifEnum.displayString)
           Motif descrip : '\(viewDescriptionMotif)'
           DURÉE         : \(duree)
           Consignée     : \(isConsignee.frenchString)
           Vérifiée      : \(isVerified.frenchString)
        """
    }
}
