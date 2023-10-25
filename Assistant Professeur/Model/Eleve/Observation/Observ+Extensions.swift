//
//  Observ+Extensions.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 19/11/2022.
//

import CoreData
import Foundation
import SwiftUI

extension ObservEntity {
    // MARK: - Computed properties

    /// Nom de l'image par défaut utilisée pour représenter un établissement
    static let defaultImageName: String = "exclamationmark.triangle"

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
        satisfies(isConsignee: false, isVerified: false) ? .red : .green
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
        try? ObservEntity.saveIfContextHasChanged()
    }

    /// Toggle l'attribut `isVerified` de la classe
    /// - Important: *Saves the context to the store after modification is done*
    func toggleIsVerified() {
        isVerified.toggle()
        try? ObservEntity.saveIfContextHasChanged()
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

extension ObservEntity {
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
        isVerified: Bool = false
    ) -> ObservEntity {
        let observ = ObservEntity.create()
        // Eleve d'appartenance.
        // mandatory
        observ.eleve = eleve

        observ.setMotif(motifEnum)
        observ.date = date
        observ.descriptionMotif = descriptionMotif
        observ.isConsignee = isConsignee
        observ.isVerified = isVerified

        try? ObservEntity.saveIfContextHasChanged()
        return observ
    }

    /// Check the correctness and consistency of all database entities of this type.
    /// - Parameters:
    ///   - errorList: Liste des erreurs trouvées.
    static func checkConsistency(
        errorList: inout DataBaseErrorList,
        tryToRepair: Bool
    ) {
        all().forEach { observ in
            if observ.eleve == nil {
                if tryToRepair {
                    do {
                        // la destruction est sauvegardée
                        try observ.delete()
                    } catch {
                        errorList.append(DataBaseError.noOwner(
                            entity: Self.entity().name!,
                            name: observ.viewDate.stringMediumDate,
                            id: observ.id
                        ))
                    }
                } else {
                    errorList.append(DataBaseError.noOwner(
                        entity: Self.entity().name!,
                        name: observ.viewDate.stringMediumDate,
                        id: observ.id
                    ))
                }
            }
        }
    }
}

// MARK: - Extension Debug

public extension ObservEntity {
    override var description: String {
        """

        OBSERVATION:
           Eleve         : \(String(describing: eleve?.displayName))
           Date          : \(date.stringShortDate)
           Motif         : \(motifEnum.displayString)
           Motif descrip : '\(viewDescriptionMotif)'
           Consignée     : \(isConsignee.frenchString)
           Vérifiée      : \(isVerified.frenchString)
        """
    }
}
