//
//  Observation+Extensions.swift
//  Assistant Professeur
//
//  Created by Lionel MICHAUD on 19/11/2022.
//

import Foundation
import CoreData
import SwiftUI

extension ObservEntity {

    // MARK: - Computed properties

    /// Wrapper of `motif`
    /// - Important: *Saves the context to the store after modification is done*
    var motifEnum: MotifEnum {
        get {
            MotifEnum(rawValue: motif) ?? .bavardage
        }
        set {
            self.motif = newValue.rawValue
            try? ObservEntity.saveIfContextHasChanged()
        }
    }

    /// Wrapper of `descriptionMotif`
    /// - Important: *Saves the context to the store after modification is done*
    @objc
    var viewDescriptionMotif: String {
        get {
            self.descriptionMotif ?? ""
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
    func satisfies(isConsignee : Bool?  = nil,
                   isVerified  : Bool?  = nil) -> Bool {
        switch (isConsignee, isVerified) {
            case (nil, nil):
                return true

            case (.some(let c), nil):
                return self.isConsignee == c

            case (nil, .some(let v)):
                return self.isVerified == v

            case (.some(let c), .some(let v)):
                return self.isConsignee == c || self.isVerified == v
        }
    }
}

// MARK: - Extension Core Data

extension ObservEntity: ModelEntityP {

    // MARK: - Type Computed Properties

    public override func awakeFromInsert() {
        super.awakeFromInsert()
        //Set defaults here
        //        self.fileName = ""
        self.date = Date.now
    }
}

// MARK: - Extension Debug

extension ObservEntity {
    public override var description: String {
        """

        OBSERVATION:
           ID            : \(id)
           EleveID       : \(String(describing: eleve?.id))
           Date          : \(date.stringShortDate)
           Motif         : \(motifEnum.displayString)
           Motif descrip : '\(viewDescriptionMotif)'
           Consignée     : \(isConsignee.frenchString)
           Vérifiée      : \(isVerified.frenchString)
        """
    }
}
