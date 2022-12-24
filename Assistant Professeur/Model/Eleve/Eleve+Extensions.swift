//
//  Eleve+Extensions.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 22/12/2022.
//

import Foundation
import CoreData


/// Un élève
extension EleveEntity {

    // MARK: - Type Properties

    @Preference(\.nameSortOrder)
    static private var nameSortOrder

    @Preference(\.nameDisplayOrder)
    static private var nameDisplayOrder

    // MARK: - Computed properties

    /// Wrapper of `sex`
    /// - Important: *Saves the context to the store after modification is done*
    var sexEnum: Sexe {
        get {
            return sex ? .male : .female
        }
        set {
            self.sex = (newValue == .male)
            try? EleveEntity.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `familyName`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewFamilyName: String {
        get {
            self.familyName ?? ""
        }
        set {
            self.familyName = newValue
            try? EleveEntity.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `givenName`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewGivenName: String {
        get {
            self.givenName ?? ""
        }
        set {
            self.givenName = newValue
            try? EleveEntity.saveIfContextHasChanged()
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
            try? EleveEntity.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `appreciation`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewAppreciation: String {
        get {
            self.appreciation ?? ""
        }
        set {
            self.appreciation = newValue
            try? EleveEntity.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `bonus`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewBonus: Int {
        get {
            Int(self.bonus)
        }
        set {
            self.bonus = Int16(newValue)
            try? EleveEntity.saveIfContextHasChanged()
        }
    }

    var displayName : String {
        switch EleveEntity.nameDisplayOrder {
            case .prenomNom:
                return "\(givenName ?? "") \(familyName ?? "")"
            case .nomPrenom:
                return "\(familyName ?? "") \(givenName ?? "")"
        }
    }

    var sortName : String {
        switch EleveEntity.nameSortOrder {
            case .prenomNom:
                return "\(givenName ?? "") \(familyName ?? "")"
            case .nomPrenom:
                return "\(familyName ?? "") \(givenName ?? "")"
        }
    }

    var additionalTime: Bool {
        false // troubleDys?.additionalTime ?? false
    }

    var additionalTimeInt: Int {
        0 // additionalTime ? 0 : 1
    }

    var groupInt: Int {
        0 // group == nil ? 0 : group!
    }

    // MARK: - Methods

    func isSameAs(_ eleve: EleveEntity) -> Bool {
        self.familyName == eleve.familyName &&
        self.givenName == eleve.givenName
    }

    /// Modifie l'attribut `sex`
    func setSex(_ newSex: Sexe) {
        self.sex = (newSex == .male)
    }

    /// Toggle l'attribut `isFlagged` de la classe
    /// - Important: *Saves the context to the store after modification is done*
    func toggleFlag() {
        isFlagged.toggle()
        try? EleveEntity.saveIfContextHasChanged()
    }

    func displayName(_ order: NameOrdering = .prenomNom) -> String {
        switch order {
            case .prenomNom:
                return "\(givenName ?? "") \(familyName ?? "")"
            case .nomPrenom:
                return "\(familyName ?? "") \(givenName ?? "")"
        }
    }

    func displayName2lines(_ order: NameOrdering = .prenomNom) -> String {
        switch order {
            case .prenomNom:
                return "\(givenName ?? "")\n\(familyName ?? "")"
            case .nomPrenom:
                return "\(familyName ?? "")\n\(givenName ?? "")"
        }
    }
}

// MARK: - Extension Core Data

extension EleveEntity: ModelEntityP {

    // MARK: - Type Computed Properties

    static func byName(familyName: String,
                       givenName: String) -> EleveEntity? {
        all()
            .first {
                $0.familyName == familyName &&
                $0.givenName == givenName
            }
    }

   static func byObjectIdentifier(objectID: EleveEntity.ID) -> EleveEntity? {
        all()
            .first { $0.id == objectID }
    }

    static func byObjectIdentifier(objectIDs: Set<EleveEntity.ID>) -> [EleveEntity] {
        all()
            .filter { entity in
                objectIDs.contains { $0 == entity.id }
            }
    }
}

// MARK: - Extension Debug

extension EleveEntity {
    public override var description: String {
        """

        ELEVE: \(displayName)
           ID      : \(id)
           Sexe    : \(sexEnum.pickerString)
           Nom     : \(displayName)
           Flagged : \(isFlagged.frenchString)
           Appréciation: \(viewAppreciation)
           Annotation  : \(viewAnnotation)
           Bonus : \(viewBonus)
        """
//           ClasseID: \(String(describing: classeId))
//           Groupe: \(String(describing: group))
//           Observations: \(String(describing: observsID).withPrefixedSplittedLines("     "))
//           Colles: \(String(describing: collesID).withPrefixedSplittedLines("     "))
//        """
    }
}
